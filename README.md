## WIP 

### これは何？  
iOSの様々なORMをCRUD操作, マイグレーションを実装して比較

使用するORM

- UserDefaults
- CoreData
- GRDB.swift
- FMDB
- Realm

---
### installed 
`pod install` and open workspace

---
### Core Data
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

---
#### Create
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
#### Read
単純にオブジェクトをfetchするのとNSFetchedResultsControllerを返すのの２種類がある。NSFetchedResultsControllerはfetchされたオブジェクトに対してIndexPathでアクセスできることやdelegateで変更通知などを行える。  
またNSFetchedResultsControllerはinit時にキャッシュ名を設定するとキャッシュを作ってくれる。  
これはキャッシュの更新日時とCoreDataのファイルの更新日時を監視しており、変更がない場合はキャッシュを使い変更がある場合は再fetchという挙動になっている。
どちらにしてもまずは読み込みたい型のリクエストを`HogeType.fetchRequest()`で作成する。  
`NSFetchRequest(entityName: String)`と`NSFetchRequest<HogeType>(entityName: String)`もあるが、どちらもTypoの可能性があるのと、前者はダウンキャストする手間があるのでおすすめしない。 
また`@FetchRequest`を`FetchResult<Entity>`につけることで簡単にfetchしたオブジェクトを使用できる。AppleのSwiftUI + CoreDataのサンプルでも使われている。   
その後、`request.predicate`に対して検索条件を設定しfetchを実行する。
- 単純にfetchするパターン
```
let id = 12
let context = container.viewContext

//requestを作成、型推論が弱いので書かないといけない
let request: NSFetchRequest<Object>  = Object.fetchReqest()

//検索条件を設定
//IN のような場合は.init("id IN @%", Array)のような感じで単純に配列を渡す
request.predicate = .init("id = @%", id)

//fetchする
let objects = try? context.fetch(request)
```
- NSFetchedResultsControllerのパターン
```
let id = 12
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

//fetchした結果にアクセスするには下記でできる
controller.fetchedObjects

//またIndexPathでもアクセスできる
controller.object(at: IndexPath(row: 0, section: 0))
```
---
#### Update  
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
#### Delete
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
