//: Playground - noun: a place where people can play

//: Playground - noun: a place where people can play

import UIKit

protocol GenericProtocol {
    typealias AbstractType
    func magic() -> AbstractType
}

struct GenericProtocolThunk<T> : GenericProtocol {
    // closure which will be used to implement `magic()` as declared in the protocol
    private let _magic : () -> T
    
    // `T` is effectively a handle for `AbstractType` in the protocol
    init<P : GenericProtocol where P.AbstractType == T>(_ dep : P) {
        // requires Swift 2, otherwise create explicit closure
        _magic = dep.magic
    }
    
    func magic() -> T {
        // any protocol methods are implemented by forwarding
        return _magic()
    }
}

struct StringMagic : GenericProtocol {
    typealias AbstractType = String
    func magic() -> String {
        return "Magic!"
    }
}

let magic : GenericProtocolThunk<String> = GenericProtocolThunk(StringMagic())
magic.magic()



protocol URLProtocol {
    typealias AbstractType
    func getURLPath()->AbstractType
}

struct URLModule<T> : URLProtocol {
    private let _url : () -> T
    
    init<P : URLProtocol where P.AbstractType == T>(_ dep : P){
        _url = dep.getURLPath
    }
    
    func getURLPath() -> T {
        return _url()
    }
}

enum GroupURL : URLProtocol{
    typealias AbstractType = String
    case GroupList
    case GroupJoin
    
    func getURLPath() -> String {
        switch self{
        case .GroupList:
            return "/list"
        case .GroupJoin:
            return "/join"
        }
    }
}

URLModule(GroupURL.GroupJoin)

class Testing{
    func tae<T : URLProtocol>(type : T){
        let magic : URLModule<String> = URLModule(type)
        
    }
}
let test = Testing()
test.tae(GroupURL.GroupJoin)



protocol AnimalProtocol {
    typealias EdibleFood
    typealias SupplementKind
    func eat(f:EdibleFood)
    func supplement(s:SupplementKind)
}

class Cow  : AnimalProtocol {
    
    
    func eat(f: String) {
        print("the Animal eats "+f)
    }
    func supplement(s: String) {
        print("the Animal supplement "+s)
    }
}

let myCow = Cow()
myCow.eat("tae")

/*



struct GenericURL<T> : URLProtocol {

private let _base : () -> T
private let _sub : () -> T

init<U : URLProtocol where U.AbstractType == T>(_ dep : U) {
_base
}

func getBaseModule() -> T {
return "sdsd"
}
func getSubModule() -> T {
return "sdsd"
}
}

struct Test : URLProtocol {
typealias AbstractType = String

func getBaseModule() -> String {
return "sdsd"
}
func getSubModule() -> String {
return "sdsd"
}
}

*/
