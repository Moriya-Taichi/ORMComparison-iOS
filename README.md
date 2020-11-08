## WIP 

### これは何？  
iOSの様々なORMをCRUD操作, マイグレーションを実装して比較

使用するORM

- UserDefaults
- CoreData
- GRDB.swift
- FMDB
- Realm

Qiitaの解説とコードでは実際に高度に使われるのを考えて1 対 1, 1 対 多, Migrationの説明を重点的におこなっているので、このREADMEにおいてはシンプルなオブジェクトを用いた簡単なCRUDの説明を行う。  
## 今回は例なのでコードにおいて`try?`でエラーを潰していますが実際に使う場合はアプリの性質を考えて適切に処理しましょう！

---
### installed 
`pod install` and open workspace

---
## Core Data
Apple公式が提供するSQLiteのORM  
Editor上でモデルを作成し、Containerのcontextを使用してCRUD操作を行う  
Read以外の各種操作の後には`context.save()`を呼ぶ必要があり、これによってCoreDataのファイルが更新される。 
マイグレーションにはLightとHeavyの２種類があり、前者は自動的にマイグレーションが行われる。  
それに対して後者は他のORMフレームワークと同じでどのプロパティがどれに対応するかなどをコードで示す必要がある。
簡単な例として、以下のような一意なidを持つ`Object`を用いて説明する

```
class Object: NSManagedObject {
    @NSManaged public var id: Int64
    @NSManaged public var name: String?
} 
```
Containerのinit方法
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
---
### Create
作成はオブジェクトを`init(context:)`で作成し、各プロパティに値をセット
その後`context.insert`を使うことでオブジェクトを挿入できる。  
1 対 多の場合は`addToHoge(object)`にオブジェクトを入れていくことで保存ができる。  
日本語の情報においては`insertedObeject`で保存するオブジェクトの生成と挿入を同時に行なっているのが多いが、  
2020年現在では下記のように`Object.init(context:)`で生成し、`context.insert(object:)`で挿入するのがAppleのSwiftUIの作例で示されている    
作成したオブジェクトには一意なObjectIDが付与されており、これPrimaryKeyとしてオブジェクトを管理している。このIDの役割を任意のプロパティに変更することはできないので、作成前には同じオブジェクトがあるかどうかを調べる必要がある。

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
---
### Read
単純にオブジェクトをfetchするのとNSFetchedResultsControllerを返すのの２種類がある。NSFetchedResultsControllerはfetchされたオブジェクトに対してIndexPathでアクセスできることやdelegateで変更通知などを行える。  
またNSFetchedResultsControllerはinit時にキャッシュ名を設定するとキャッシュを作ってくれる。  
これはキャッシュの更新日時とCoreDataのファイルの更新日時を監視しており、変更がない場合はキャッシュを使い変更がある場合は再fetchという挙動になっている。
どちらにしてもまずは読み込みたい型のリクエストを`HogeType.fetchRequest()`で作成する。  
`NSFetchRequest(entityName: String)`と`NSFetchRequest<HogeType>(entityName: String)`もあるが、どちらもTypoの可能性があるのと、前者はダウンキャストする手間があるのでおすすめしない。 
また`@FetchRequest`を`FetchResult<Entity>`につけることで簡単にfetchしたオブジェクトを使用できる。AppleのSwiftUI + CoreDataのサンプルでも使われている。   
その後、`request.predicate`に対して検索条件を設定しfetchを実行する。
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
---
### Update  
更新はオブジェクトのプロパティを変更で行う。
なので一旦、更新対象のオブジェクトをfetchする必要がある。

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
`context.delete(object)`で消去できる。  
updateと同じで削除対象のオブジェクトを一旦fetchする必要がある

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

## Realm
CoreDataなどのSQLite系のORMとは違い  
独自のDBとORMを提供しているOSS  
CoreDataと同じで元がObj-cなのでSwift的にモデルをStructで定義して使うことができない  
使い方としては保存したいオブジェクトをclassで宣言し`Object`を継承
`Realm`のインスタンスを通して各操作を行う  
1 対 多の関係ではプロパティに`List<HogeObject>`を使い  
1 対 1の場合はプロパティにそのまま`HogeObject`を使う  
どちらの場合でも参照しているだけなので更新や削除の際に親のオブジェクトからやる必要はない。  
簡単な例として、以下のような一意なidを持つ`Entity`を用いて説明する
```
class Entity: Object {
    @objc dynamic var id: Int = -1
    @objc dynamic var name: String = ""

    static override func primaryKey() -> String? {
        return "id"
    }
}
```
Realmのinit
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
---

## GRDB
2015年にリリースされたSQLiteのORM  
モデルに各種protocolやclassを継承させていくことでDBで扱えるようになる。  
素のSQLもサポートされており、更新頻度高い(2020/10において) 
のでSQLを書きたい場合でもFMDBよりこちらの方がおすすめできる。   
保存する対象は`Record`のサブクラスにするか  
Structで定義し各種protocolに準拠させる。  
公式としては`Record`でサブクラスを作るのはoldで、  
structを`FetchableRecord`や`PersistableRecord`に準拠させるのがSwifty  
と述べている。今回はSwiftyな方を解説する。  
まず各種Protocolについて解説する。  
- `Read`できるようにする系
   - `FetchableRecord`  
これに準拠するとDBからfetchするメソッドが付与される。  
またプロパティ名を元にDBのカラムからinitするのが付与される。  
initではこの先紹介するモデルのように`row["hoge"]`といった風に  
カラム名を指定して初期化する。  
`String, ColumnExpression`に準拠したenumも使用可能で  
`row[Enum.hoge]`といった記述もできる。  
`Decodable`に準拠している場合はinitを書く必要はない  

  - `TableRecord`   
これに準拠すると、SQLを生成してくれるようになる  
また`PrimaryKey`での検索が可能になる
<br>
<br>


- `Update`などの操作を可能にする系
  - `MutablePersistableRecord(TableRecord, EncodableRecord)`
  - `PersistableRecord(MutablePersistableRecord)`  
`EncodableRecord`というのも存在するが直接使うことはない。   
どちらのProtocolも準拠すると`Update`,`Create`,`Delete`が可能になる。  
使い方については  
`struct`で`Auto Increment主キーがある`場合は`MutablePersistableRecord`に準拠し`didInsert()`の中でrowIDをモデルのidにセットする実装をする。   
`モデルがclass` or `structでAuto Incrementな主キーがない`場合は`PersistableRecord`に準拠、`didInsert()`は実装しない。  
どちらも`TableRecord`を含んでいるのでデータベースに保存するモデルは  
上二つのどちらか + `FetchableRecord`に準拠すれば全ての操作ができる。  

Databaseへのアクセスは`Queue`と`Pool`があるが、  
訳のわからない場合は`Queue`を公式はおすすめしている。  
叩くメソッドは同じなのでデータベースに対してマルチスレッドで  
大量にアクセスしない限りは`Queue`で十分である。


- モデルの定義
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
- DBの接続
```
//Queue
let dbQueue = try DatabaseQueue(path: "/path/to/database.sqlite")

//Pool(SQLiteをWALモードで開く)
let dbPool = try DatabasePool(path: "/path/to/database.sqlite")

//InMemory(Queueのみ)
let dbQueue = try DatabaseQueue()
```
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
---
## FMDB
古くからあるSQLiteのWrapper  
基本的にはSQLを書いて実行していく、  
そのためN+1をはじめとしたパフォーマンス面での調整はエンジニアに委ねられる。
かつマルチスレッドでの動作もエンジニアに委ねられる。  
他のORMと同じで初めにpathを指定して`FMDatabase`を初期化し各種操作を行う。
pathを指定しない場合はinMemoryで動作する。    
公式としてはFMDatabaseのインスタンスを共有するのが推奨していなく、  
様々なスレッドで共有される場合は`FMDatabaseQueue`か`FMDatabasePool`を  
使用するように推奨されている。  
紹介してきたORMの中では一番更新頻度が少なく、かつSQLの実行はGRDBでサポートされているので積極的にこれを選択する理由はない。

- 説明に使うモデル
```
struct Object {
    let id: Int
    let name: String
}
```
- DBへの接続
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
---