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
Read以外の各種操作の後には`context.save()`を呼ぶ必要がある  
マイグレーションにはLightとHeavyの２種類があり、前者は自動的にマイグレーションが行われる。  
それに対して後者は他のORMフレームワークと同じでどのプロパティがどれに対応するかなどをコードで示す必要がある。

---
#### Create
作成はオブジェクトを`init(context:)`で作成し、各プロパティに値をセット
その後`context.insert`を使うことで

```
//オブジェクトの生成
let context = container.viewContext
let newObject = Object(contex)

//オブジェクトのプロパティにセット
newObject.hoge = "HogeHoge"
newObject.id = Int64(12)

//挿入
try? context.insert(newObject)

//保存
try? context.save()
```

#### Read
単純にオブジェクトをfetchするのとNSFetchedResultsControllerを返すのの２種類がある。NSFetchedResultsControllerはfetchされたオブジェクトに対してIndexPathでアクセスできることやdelegateで変更通知などを行える。  
またNSFetchedResultsControllerはinit時にキャッシュ名を設定するとキャッシュを作ってくれる。  
これはキャッシュの更新日時とCoreDataのファイルの更新日時を監視しており、変更がない場合はキャッシュを使い変更がある場合は再fetchという挙動になっている。
どちらにしてもまずは読み込みたい型のリクエストを`HogeType.fetchRequest()`で作成する。  
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

#### Update

```

```

#### Delete

```

```
