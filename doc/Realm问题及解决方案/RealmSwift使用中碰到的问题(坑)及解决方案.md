

最近做个项目是需要大量的本地数据交互保存持久化操作，由于是新项目所以我们打算使用比较新颖的框架来进行开发，最后经过筛选使用了Realm来作为本地数据操作框架。name我们为什么选择realm呢？大部分的数据库框架还是使用2000年的SQLite，大部分的移动应用还是直接或间接的使用SQLite来作为本地数据库比如：FMDB、Couchbase Lite，Core Data，ORMLite，而Realm是专门为移动端设计的框架，最后我们经过比对选择了Realm。
首先[Realm](https://realm.io) 是一个跨平台的移动数据库引擎，其性能要优于  FMDB、Couchbase Lite，Core Data，ORMLite - [移动端数据库性能比较](https://realm.io/blog/introducing-realm/#fast), 我们可以在 [Android 端 realm-java](https://github.com/realm/realm-java)Kotlin也可以使用，iOS端:[Realm-Cocoa](https://github.com/realm/realm-cocoa/)，同时支持 OC 和 Swift两种语言开发。使用操作简单、性能优异、跨平台、开发效率得到了大大提高(省去了数据模型与表存储之间转化的很多工作)、配备可视化数据库查看工具。这些都满足了我们项目的需要。
对于Realm的使用今天不在这里介绍，网上可以搜到很多具体的使用方法，也可以到[官网文档](https://realm.io/docs/swift/latest/)上查看Api。我们主要剖析下在项目开发过程中遇到到问题、疑难杂症和解决的方案。
######我们先来看下Realm不支持的地方及需要注意的地方：
1.不支持联合主键
2.不支持自增长主键
3.不能跨线程共享realm实例，不同线程中，都要创建独立的realm实例，只要配置(configuration)相同，它们操作的就是同一个实体数据库。
4.存取只能以对象为单位,不能只查某个属性，使用sql时，可以单独查询某个(几个)独立属性，比如 select courseName from Courses where courseId = "001"，而在realm中 + (RLMResults *)objectsWhere类似这种返回的是RLMResults对象。查询相关函数，得到的都是对象的集合，相对不够灵活。
5.被查询的RLMResults中的对象，任何的修改都会被直接同步到数据库中，所以对对象的修改都必须被包裹在beginWriteTransaction中，Swift要包裹在try! Realm().write { }中，使用时要注意。
例如：

```
let results = SXRealm.queryByAll(DetailModel.self)
 let item = results[0]
  try!  Realm().write {//修改数据，必须在此操作中，否则会造成Crash。
          item.uploadStatus = 2
          item.uploadFailedDes = "上传失败！"
   }        
```

6.RLMResults与线程问题，在主线程查出来的数据，如果在其他线程被访问是不允许的，运行时会报错。
例如：

```
//这种是错误的，只能访问同一线程的realm数据。
 RLMResults *results = [Course objectsWhere:@"courseId = '001'"];
 Course *getCourse = [results objectAtIndex:0];
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"%@",results);
        NSLog(@"%@",getCourse.courseName);
    });
```

7.auto-updating机制，十分方便，并保证了数据的实时性，但是在个别情况下，也许这种机制并不需要，可能会导致一些意外，所以需要注意。(OC举例)

```
    RLMRealm *realm = [RLMRealm defaultRealm];
    Course *course = [[Course alloc] init];
    course.courseId = @"001";
    course.courseName = @"语文";
    [realm transactionWithBlock:^{
        [realm addObject:course];
    }];
    
    Course *getCourse1 = [Course objectsWhere:@"courseId = '001'"].firstObject;
    NSLog(@"%@",getCourse1);
    [realm transactionWithBlock:^{
        getCourse1.courseName = @"体育";
    }];
    
    NSLog(@"%@",course);

```

（1）第一次查询后，result中有一条记录，后面即便没有执行重新查询，新加入的数据，自动就被同步到了result中。

```
        RLMRealm *realm = [RLMRealm defaultRealm];
    Course *course = [[Course alloc] init];
    course.courseId = @"001";
    course.courseName = @"语文";
    [realm beginWriteTransaction];
    [Course createOrUpdateInDefaultRealmWithValue:course];
    [realm commitWriteTransaction];
    
    RLMResults *result = [Course allObjects];
    NSLog(@"%@",result);
    
    Course *course2 = [[Course alloc] init];
    course2.courseId = @"002";
    course2.courseName = @"数学";
    [realm beginWriteTransaction];
    [Course createOrUpdateInDefaultRealmWithValue:course2];
    [realm commitWriteTransaction];
    
    NSLog(@"%@",result);
```

（2）开始查询出课程id为001的课程模型getCourse1、getCourse2的课程名为语文，后面仅对getCourse2进行修改后，getCourse1的属性也被自动同步更新了。

```
    RLMRealm *realm = [RLMRealm defaultRealm];
    Course *course = [[Course alloc] init];
    course.courseId = @"001";
    course.courseName = @"语文";
    [realm beginWriteTransaction];
    [Course createOrUpdateInDefaultRealmWithValue:course];
    [realm commitWriteTransaction];
    
    Course *getCourse1 = [Course objectsWhere:@"courseId = '001'"].firstObject;
    NSLog(@"%@",getCourse1);
    Course *getCourse2 = [Course objectsWhere:@"courseId = '001'"].firstObject;
    [realm beginWriteTransaction];
    getCourse2.courseName = @"体育";
    [realm commitWriteTransaction];
    NSLog(@"%@",getCourse1);
```

(3).在别的线程中的修改，也会被同步过来

```
    Course *getCourse1 = [Course objectsWhere:@"courseId = '001'"].firstObject;
    NSLog(@"%@",getCourse1);
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        RLMRealm *realm = [RLMRealm defaultRealm];
        Course *getCourse2 = [Course objectsWhere:@"courseId = '001'"].firstObject;
        [realm beginWriteTransaction];
        getCourse2.courseName = @"体育";
        [realm commitWriteTransaction];
        NSLog(@"%@",getCourse2);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@",getCourse1);
        });
    });

```

8.从realm数据库读取出的数据模型，setter/getter方法会失效，集成realmObject的实力类setter/getter方法会失效，当赋值的时候不会走set方法。
到这里我们已经对Realm有了一定的了解，也熟悉了它的机制。
#####下面来说下在开发项目的时候具体碰到的问题：
######一.数据解析转换存储，反转换问题
由于项目中操作数据转换的地方多，需要Json转Model存入realm，获取realm数据Model转换成Json，但是realmSwift只支持把json转换成realm所需的存储Model，而不支持反转。而Android的realm却可以，这让我很苦恼，而我又不想手动一二个一个来转换，1是我们数据量太多，我觉得这种太耗费精力2是也觉得这样做有些low，于是乎遇到了瓶颈，逛各种技术论坛也没有找到解决方案。静下心来开始思考看HandyJson和realm的源码，最后发现原来realm的数据类型是它自己定义的数组类型，而不是继承iOSSwift的数据类型，这就造成HandyJson解析库识别不了这些数据类型，最后导致没办法数据相互转换。
![realm数据类型](https://upload-images.jianshu.io/upload_images/1652523-d479fba8374889d6.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
解决方案：
1.建立数据Model的时候需要在BaseModel里添加两个方法函数解决list解析

```
import Foundation
import RealmSwift
import Realm
import HandyJSON

class BaseRLMObject: Object, NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        return type(of: self).init()
    }
    
    //这个父类添加的属性，子类解析不会赋值，因此在子类各自添加
//    @objc dynamic var primaryKey = UUID().uuidString
//    override static func primaryKey() -> String? {
//        return "primaryKey"
//    }
    
    //解析的Array数据添加到realm方法 例如：请求的Array数据需要添加到realm List数据库时调用
     //注意点：realmlist直接.append(objectsIn:)添加swift数组的时候，是可以添加到realmlist中的，原因realmlist数组能够识别swift数组类型，但是反之就不行
    func addRealmData(){
        
    }
   
    //realm List数据传递给正常的Array方法 例如：realm List数据转换成model Array时调用
    //注意点：swift数组直接.append(contentsOf:)添加realmlist的时候，是添加不到正常数组里的，原因正常的swift数组不识别realmlist类型，但是反之就可以
    func addOriginalData(){
        
    }

}

```

2.子类需要继承父类，然后实现这两个方法，并且相同数组key属性都需要创建两个（一个是Json转换Realm数据需要，一个是Realm数据转换Json需要），每层都需要实现。
3.需要在HandyJson的ignoredProperties中忽略正常的list数据，否则会在realm数据库的字段表中出现该字段。
4.如果Bool型、Int型、Float型、Double型是需要非可空值的形式，则不需要特殊处理，但是如果这四种类型的数据是可空值形式，则需要特殊处理，转换成String类型。原因是Bool、Int、Float、Double的可空值形式是RealmOptional<类型>()，解析库识别不了realm自己定义的数据类型。
具体代码：

```
import Foundation
import RealmSwift
import Realm
import HandyJSON

class PhotoModel : BaseRLMObject, HandyJSON {
    @objc dynamic var primaryKey = UUID().uuidString
    override static func primaryKey() -> String? {
        return "primaryKey"
    }

//    let id = RealmOptional<Int>()
    @objc dynamic var id: String? = nil
//    let vehicleId = RealmOptional<Int>()
    @objc dynamic var type: String? = nil
    @objc dynamic var delFlag:Bool = false // 删除标记
    let damageInfoList_realm: List<DamageInfoModel> = List<EQSDamageInfoModel>()//损伤点
    var damageInfoList: [DamageInfoModel] = []
    
    override static func ignoredProperties() -> [String] {
        return ["damageInfoList"]
    }
    
    override func addRealmData() {
        for item in self.damageInfoList {
            item.addRealmData()
        }
        if self.damageInfoList_realm.count > 0 && self.damageInfoList.count > 0 {
            self.damageInfoList_realm.removeAll()
        }
        self.damageInfoList_realm.append(objectsIn: self.damageInfoList)
    }
    
    override func addOriginalData() {
        if self.damageInfoList.count > 0 && self.damageInfoList_realm.count > 0{
            self.damageInfoList.removeAll()
        }
        
        for item in self.damageInfoList_realm {
            item.addOriginalData()
            self.damageInfoList.append(item)
        }
    }
}
```

在使用的时候每次转换都需要调用add方法

```
//添加到realm数据库
 if let object = JSONDeserializer<Model>.deserializeFrom(json:  json) {
                            object.addRealmData()
                            SXRealm.addAsync(object)
                    } 
//realm数据库数据转换成Json
 let model =  SXRealm.queryByPrimaryKey(DetailModel.self, primaryKey: detailModel.primaryKey)
 guard model == nil else {
      SXRealm.doWriteHandler {
              model.addOriginalData()   
      }
     let json =   mode.toJSON()!
 }
 
```
#####二.primaryKey主键问题
经过测试逐渐定义不能在父类基础类定义，必须要在各个子类都要定义。Realm的机制可能是检测到这个字段有值就不会重新自动赋值，所以说不能偷懒在父类定义。

```
//这个父类添加的属性，子类解析不会赋值，因此在子类各自添加
   @objc dynamic var primaryKey = UUID().uuidString
    override static func primaryKey() -> String? {
        return "primaryKey"
    }
```

#####三.删除对应数据问题
根据Realm提供的删除方法，只能删除该对象，却不能删除该对象相关联的对象，这点感觉很坑，如果只删除该对象后，其相关联的对象就会变成脏数据，永远保存在数据库中，会造成体积越来越大。
解决方案：
1.采用代码批量删除方法，把该对象下边的list中的数据循环删除（先删除子对象，再删除外层对象）

```
 func deleteOrganizationUpgradeRealm() {
        let data = SXRealm.BGqueryByAll(OrganizationItem.self)
        
        if data.count > 0 {
            SXRealm.BGdelete(SXRealm.BGqueryByAll(ChildItem.self))
            SXRealm.BGdelete(SXRealm.BGqueryByAll(OrganizationItem.self))
        }
    }

  static func BGdelete<T: Object>(_ objects: Results<T>) {
        
        try! Realm().write {
            try! Realm().delete(objects)
        }
    }
```

2.采用递归方式删除（对于复杂数据结构，但是数据量超级大的时候不建议使用此方法）

```
static func BGdeleteRealmCascadeObject(object:Object){
        for property in object.objectSchema.properties {
            if property.type == .object{
                if property.isArray{
                    let list:RLMArray<AnyObject> = RLMArray(objectClassName: property.objectClassName!)
                    list.addObjects(object.value(forKeyPath: property.name) as! NSFastEnumeration)
                    for i in 0..<list.count {
                        deleteRealmCascadeObject(object: list.object(at: i) as! Object)
                    }
                    
                } else {
                    let object:SXRLMObject = object.value(forKeyPath: property.name) as! SXRLMObject
                    if !object.isInvalidated{
                         try! Realm().delete(object)
                    }
                   
                }
                
            }
        }
        if !object.isInvalidated{
            try! Realm().delete(object)
        }
    }
```

#####四.修改更新操作realm对象时，需要在写入操作中实现，并且只能有一层写入操作方法。

```
//在这如果做了doWrite操作，name在addOriginalData方法中就不能做都Write操作，否则Crash。
SXRealm.doWriteHandler {
             model.addOriginalData()
  }

 static func doWriteHandler(_ clouse: @escaping ()->()) { // 这里用到了 Trailing 闭包
        try! sharedInstance.write {
            clouse()
        }
    }
```

#####五.realm数据对象不能带alloc、new、copy、mutableCopy之类的跟iOS语言相关的关键字、前缀字段，否则会造成Crash。（这点感觉好蛋疼）那么我们只能够跟之前操作list的时候一样，同样的原理做桥接。
######解决方法：

```
//解析使用  realm 不能有new alloc "copy", "mutableCopy" 等关键字前缀字段
var newVehicleSuggestionPrice: String? = nil
var newVehicleNetPrice:String? = nil
@objc dynamic var vehicleSuggestionPrice_realm: String? = nil
@objc dynamic var vehicleNetPrice_realm: String? = nil

//忽略realm数据库对应字段
override static func ignoredProperties() -> [String] {
       return ["newVehicleSuggestionPrice","newVehicleNetPrice"]
 }

 //注意点：realmlist直接.append(objectsIn:)添加swift数组的时候，是可以添加到realmlist中的，原因realmlist数组能够识别swift数组类型，但是反之就不行
 override func addRealmData() {
        self.vehicleSuggestionPrice_realm = self.newVehicleSuggestionPrice
        self.vehicleNetPrice_realm = self.newVehicleNetPrice
  }

//注意点：swift数组直接.append(contentsOf:)添加realmlist的时候，是添加不到正常数组里的，原因正常的swift数组不识别realmlist类型，但是反之就可以
 override func addOriginalData() {
         self.newVehicleSuggestionPrice = self.vehicleSuggestionPrice_realm
         self.newVehicleNetPrice  = self.vehicleNetPrice_realm
  }
```

#####六.系统的数组和realm数组转换问题
如果需要把系统的数组中的数据添加到realm数组中可以直接调用realm数组的.append(objectsIn: Sequence)方法

```
public func append<S: Sequence>(objectsIn objects: S) where S.Iterator.Element == Element {
        for obj in objects {
            _rlmArray.add(dynamicBridgeCast(fromSwift: obj) as AnyObject)
        }
}
```

但是如果需要把realm数组中的数据添加到系统的数组中，就不能使用系统的.append(contentsOf: Sequence)方法，而需要自己遍历循环一个一个添加

```
//list_realm:realm数组类型变量    list:系统的长长数组类型变量
 for item in self.list_realm {
       self.list.append(item)
 }
```

#####七.description HandyJson解析问题
这个问题其实不是realm的问题，而是HandyJson的问题，HandyJson的时候对于Json中的description字段是解析不成功的，按照正常操作是需要进行一层转换，但是又由于与realm的Model是同一个Model，两者共同使用就造成了问题的出现，想要转换的变量必须以var来修饰，而realm中则需要@objc dynamic var来修饰，因此就出现了这个问题
######解决方法：
需要中间创建个变量进行桥接，在转换的时候同时进行赋值操作转换。

```
import Foundation
import RealmSwift
import Realm
import HandyJSON

class XXXModel: SXRLMObject, HandyJSON{
    @objc dynamic var primaryKey = UUID().uuidString
    override static func primaryKey() -> String? {
        return "primaryKey"
    }
   
    //解析使用description关键字系统不支持
    var sdescription: String = ""//图片描述
    @objc dynamic var description_realm: String = ""//图片描述
    func mapping(mapper: HelpingMapper) {
        // specify 'description' field in json map to 'sdescription' property in object
        mapper <<<
            self.sdescription <-- "description"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["sdescription"]
    }
    
    override func addRealmData() {
         self.description_realm = self.sdescription
    }
    
    override func addOriginalData() {
        self.sdescription = self.description_realm
    }
}
```

#####*以上就是RealmSwift的一些特性和我们项目中实践过程踩过的坑。如果之后使用过程中碰到问题，会持续更新。




