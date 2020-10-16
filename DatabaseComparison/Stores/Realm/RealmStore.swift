import Foundation
import RealmSwift

final class RealmStore {

    let realm: Realm

    init (realm: Realm) {
        self.realm = realm
    }

    func read<T: Object>(t: T){
        realm.objects(T.self)
    }

    func create () {

    }

    func delete() {
        
    }
}
