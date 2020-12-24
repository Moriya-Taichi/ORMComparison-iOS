### これは何？  
iOSの様々なORMをCRUD操作, マイグレーションを実装して比較

動作環境

- XCode 12.1
- CocoaPod v1.9.1

使用するORM

- UserDefaults
- CoreData
- GRDB.swift v4.14.0
- FMDB v2.7.5
- Realm v5.4.4

Qiita(WIP)の解説とコードでは実際に高度に使われるのを考えて1 対 1, 1 対 多, Migrationの説明を重点的におこなっているので、このREADMEにおいてはシンプルなオブジェクトを用いた簡単なCRUDの説明を行う。  
## 今回は例なのでコードにおいて`try?`でエラーを潰していますが実際に使う場合はアプリの性質を考えて適切に処理しましょう！

---
### installation
`pod install` and open generated workspace

---
## Core Data
- 例に用いるモデル
```
class Object: NSManagedObject {
    @NSManaged public var id: Int64
    @NSManaged public var name: String?
} 
```
<br>  

- DBの接続
```
//DB名を選んで初期化、ファイルがあればロードしなければ作成する
let container = NSPersistentContainer(name: "hogehoge")

//テストなどでInMemoryで動かしたい場合は
container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
//これでもInMemoryにできる
let description = NSPersistentStoreDescription()
description.type = NSInMemoryStoreType
container.persistentStoreDescriptions = [desription]
```
<br>

---
### Create

```
func create(id: Int, name: String) {
    //オブジェクトの生成
    let context = container.viewContext
    let newObject = Object(contex)

    //オブジェクトのプロパティにセット
    newObject.name = name
    newObject.id = Int64(id)

    //挿入
    try? context.insert(newObject)

    //保存
    try? context.save()
}

```
<br>

---
### Read
- 単純にfetchするパターン
```
func read() -> [Object]? {
    let context = container.viewContext

    //requestを作成、型推論が弱いので書かないといけない
    let request: NSFetchRequest<Object>  = Object.fetchReqest()

    //検索条件の例
    //IN のような場合は.init("id IN @%", Array)のような感じで単純に配列を渡す
    // request.predicate = .init("id = @%", id)

    //fetchする
    return try? context.fetch(request)   
}
```
<br>

- NSFetchedResultsControllerのパターン
```
func readWithController() -> NSFetchedResultsController<Object> {
    let context = container.viewContext
    let request: NSFetchRequest<Object>  = Object.fetchReqest()
    let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
    )
    //fetch
    try? controller.performFetch()
    return controller
}

//fetchした結果にアクセスするには下記でできる
controller.fetchedObjects

//またIndexPathでもアクセスできる
controller.object(at: IndexPath(row: 0, section: 0))
```
<br>

---
### Update  

```
func update(id: Int, name: String) {

    let context = container.viewContext()

    //idが同じobjectを1個fetchするようにrequestを作成
    let request: NSFetchRequest<Object> = Object.fetchRequest()
    request.predicate = .init("id = @%", id)
    request.fetchLimit = 1

    //fetchする、objectがなければ何もせずにreturn
    guard let result = try? context.fetch(request).first else {
        return
    }

    //nameを更新
    result.name = name

    //更新を保存
    try? context.save()
}
```
---
### Delete

```
func delete(id: Int) {
    
    let context = container.viewContext()

    //idが同じobjectを1個fetchするようにrequestを作成
    let request: NSFetchRequest<Object> = Object.fetchRequest()
    request.predicate = .init("id = @%", id)
    request.fetchLimit = 1

    //fetchする、objectがなければ何もせずにreturn
    guard let result = try? context.fetch(request).first else {
        return
    }

    //オブジェクトの削除
    context.delete(result)

    //削除したのを保存
    try? context.save()
}
```
<br>

---
## Realm
- 例に用いるモデル 
```
class Entity: Object {
    @objc dynamic var id: Int = -1
    @objc dynamic var name: String = ""

    static override func primaryKey() -> String? {
        return "id"
    }
}
```
<br>

- DBの接続
```
let configuration: Realm.Configuration = .init(
            //RealmのファイルのURL
            fileURL: URL?,
            
            //InMemoryにしたい場合は設定する
            //設定するとfileURLがnilに設定される
            inMemoryIdentifier: String?,
            
            //mongoDB realm(下)と同期する際の設定
            //https://www.mongodb.com/realm/mobile/sync
            syncConfiguration: SyncConfiguration?,
            
            //データの暗号化に利用する64Bのキー
            encryptionKey: Data?,
            
            //read onlyにするかどうか
            readOnly: Bool,
            
            //スキーマのバージョン
            //migrationの時に上げる
            schemaVersion: UInt64,
            
            //migrationで実行するブロック
            //migrationの処理はここに書く
            migrationBlock: MigrationBlock?,
            
            //migrationが必要な時に既存のデータを消すかどうか
            //テーブルは更新したいけどデータの移行はしない場合はtrue
            deleteRealmIfMigrationNeeded: Bool?,

            //realm起動時に呼び出されるブロック
            //データの使用量と空き容量が渡されるので
            //圧縮するかどうかを判断してBoolで返す
            shouldCompactOnLaunch: ((Int, Int) -> Bool)?,
            
            //格納するObjectのタイプを明示的に指定したい場合は設定する
            objectTypes: [Object.Type]?
        )
let realm = .init(configuration: configuration)
```
<br>

---
### Create
```
func create(id: Int, name: String) {
    //トランザクション
    try? realm.write {
        //オブジェクトの作成
        let newEntity = Entity()
        newEntity.id = id
        newEntity.name = name
        
        //追加
        try? realm.add(newEntity)
    }
} 
```
---
### Read
```
func read() -> [Entity] {
    return realm.objects(Entity.self)
}
```
---
### Update
- CoreDataと同じやり方
```
func update(id: Int, name: String) {
    //PrimaryKeyを使ってオブジェクトを取得
    guard let entity = realm.object(
        ofType: Entity.self, 
        forPrimaryKey: id
    ) 
    else {
        return
    }

    //トランザクション
    try? realm.write {
        //更新
        entity.name = name
    }
}
```
<br>

- Createとほぼ同じやり方
```
func update(id: Int, name: String) {
    //トランザクション
    try? realm.write {
        //オブジェクトの作成
        let newEntity = Entity()
        newEntity.id = id
        newEntity.name = name

        //updateにmodifiedを設定すると、
        //同じkeyのオブジェクトがあったらupdateしてくれる
        try? realm.add(newEntity, update: .modified)
    }
}
```
---
### Delete
```
func delete(id: Int) {
    //PrimaryKeyを使ってオブジェクトを取得
    guard let entity = realm.object(
        ofType: Entity.self, 
        forPrimaryKey: id
    ) 
    else {
        return
    }

    //トランザクション
    try? realm.write {
        //削除
        try? realm.delete(entity)
    }
}
```
<br>

---

## GRDB

- 例に用いるモデル
```
struct Object: FetchableRecord, Decodable, PersistableRecord {
    let id: Int
    let name: String

    //Decodableが無い場合
    // init(row: Row) {
    //  id = row["id"]
    //  name = row["name"]
    //}
}
```
<br>

- DBの接続
```
//Queue
let dbQueue = try DatabaseQueue(path: "/path/to/database.sqlite")

//Pool(SQLiteをWALモードで開く)
let dbPool = try DatabasePool(path: "/path/to/database.sqlite")

//InMemory(Queueのみ)
let dbQueue = try DatabaseQueue()
```
<br>

- テーブルの作成
```
func createTable() {
    //書き込み
    try? dbQueue.write { db in
        //テーブルの作成、同名が無い場合のみ実行される
        try? db.create(
            table: String(describing:
                type(of: Object.self)
            ),
            temporary: false,
            ifNotExists: true
        ) { table in
            //各カラムの設定
            table.primaryKey(["id"])
            table.column("name", .text).notNull()
            table.column("id", .integer).notNull()
        }
    }
}
```
<br>

---
### Create
```
func create(object: Object) {
    //書き込み
    try? databaseQueue.write { database in 
        //挿入
        try? object.insert(database)
    }
}
```
---
### Read
```
func read() -> [Object]? {
    //読み込み
    return databaseQueue.read { database in 
        //fetch
        return try? Object.fetchAll(database)
    }
}
```
---
### Update
```
func update(object: Object) {
    //書き込み
    try? databaseQueue.write { database in 
        try? object.update(database)
    }
}
```
---
### Delete
```
func delete(object: Object) {
    try? databaseQueue.write { database in
        try? obect.dalete(database)
    }
}
```
<br>

---
## FMDB

- 例に用いるモデル
```
struct Object {
    let id: Int
    let name: String
}
```
<br>

- DBの接続
```
//DBのpath
let databasePath = try! FileManager.default
                .url(
                    for: .applicationSupportDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: true
                )
                .appendingPathComponent("hoge.sqlite")
//init
let database = FMDatabase(url: databasePath)

//Queue
let queue = FMDatabaseQueue(url: databasePath)
//Pool
let pool = FMDatabasePool(url: databasePath)

//InMemory
let database = FMDatabase()
```
<br>

- テーブルの作成
```
func createTable() {
    
    //テーブルを作成するSQL
    let createTableSQL = "CREATE TABLE IF NOT EXISTS " +
    "objects (" +
    "id INTEGER PRIMARY KEY, " +
    "name TEXT" +
    ");"

    //データベースをオープン
    database.open()

    //SQLの実行
    try? database.executeUpdate(
        createTableSQL, 
        values: nil
    )
    
    //変更を保存 
    database.close()
}
```
<br>

---
### Create 
```
func create(object: Object) {
    //INSERTするSQL
    let insertSQL = "INSERT INTO " +
    "objects (id, name)" +
    "VALUES " +
    "(?, ?);"
    
    //データベースをオープン
    database.open()

    //SQLを実行
    try? database.execureUpdate(
        insertSQL, 
        values: [object.id, object.name]
    )

    //変更を保存 
    database.close()
}
```
---
### Read 
```
func read() -> [Object] {
    
    //SELECTするSQL
    let selectSQL = "SELECT " +
    "id, name " + 
    "FROM " +
    "objects;" + 
    "ORDER BY id;"
    var objects: [Object] = []
    
    //データベースをオープン
    database.open()

    //SQLの実行
    if let result = try? database.executeQuery(
        selectSQL,
        values: nil
    ) {
        //
        while result.next() {
            let object = Object(
                id: Int(result.int(forColumnIndex: 0)),
                name: result.string(forColumnIndex: 1) ?? ""
            )
            objects.append(object)
        }
    }

    //データベースを閉じる 
    database.close()

    return objects
}
```
---
### Update 
```
func update(object: Object) {
    
    //UPDATEするSQL
    ler updateSQL = "UPDATE " + 
    "objects " + 
    "SET" +
    "name = ?" +
    "WHERE " +
    "id = ?;"
    
    //データベースをオープン
    database.open()

    //SQLの実行
    try? database.executeUpdata(
        updateSQL,
        values: [
            object.name,
            object.id
        ]
    )

    //変更を保存 
    database.close()
}
```
---
### Delete 
```
func delete(object: Object) {
    
    //DELETEするSQL
    let deleteSQL = "DELETE FROM objects WHERE id = ?;"
    
    //データベースをオープン
    datebase.open()

    //SQLの実行
    try? database.executeUpdate(
        deleteSQL, 
        values: [object.id]
    )

    //変更を保存 
    database.close()
}
```
