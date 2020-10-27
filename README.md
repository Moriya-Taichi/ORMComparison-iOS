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
日本語の情報においては`insertedObeject`で保存するオブジェクトの生成と挿入を同時に行なっているのが多いが、  
2020現在では下記のように`Object.init(context:)`で生成し、`context.insert(object:)`で挿入するのがAppleのSwiftUIの作例で示されている  
またRead以外の各種操作の後には`context.save()`を呼ぶ必要がある  
マイグレーションにはLightとHeavyの２種類があり、前者は自動的にマイグレーションが行われる。  
それに対して後者は他のORMフレームワークと同じでどのプロパティがどれに対応するかなどをコードで示す必要がある。

---
#### Create

```
//オブジェクトの生成
let context = container.viewContext
let newObject = Object(contex)

//オブジェクトのプロパティにセット
newObject.hoge = "HogeHoge"
newObject.id = Int64(12)

//挿入
context.insert(newObject)

//保存
context.save()
```

#### Read
単純にオブジェクトをfetchするのとNSFetchedResultsControllerを返すのの２種類がある
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
