private enum Status {
    case none
    case resize
}

public class MyDictionary<Key: Hashable, Value> {
    
    private typealias Element = (key: Key, value: Value)
    private typealias Bucket = [Element]
    private var buckets: [Bucket]
    
    private let maxLoadFactor = 0.6
    
    private(set) public var count = 0
    
    private var size: Int { return buckets.count }
    
    private var isEmpty: Bool { return count == 0 }
    
    private var currentLoadFactor: Double { return Double(count) / Double(size) }
    
    
    
    public init(capacity: Int) {
        assert(capacity > 0)
        buckets = Array<Bucket>(repeatElement([], count: capacity))
    }
    
    private func hash(forKey key: Key) -> Int {
        return abs(key.hashValue % buckets.count)
    }
    
    public func append(key: Key,value: Value) {
        let hash = self.hash(forKey: key)
        let existedElement = checkKey(forKey: key)
        if existedElement != nil {
            updateValue( value,forKey: key)
        } else {
            buckets[hash].append((key: key, value: value))
            count += 1
            resize()
        }
    }
    
    private func checkKey(forKey key: Key) -> (key: Key, value: Value)? {
        let hash = self.hash(forKey: key)
        for element in buckets[hash] {
            if key == element.key {
                count -= 1
                return element.self
            }
        }
        return nil
    }
    
    public func value(forKey key: Key) -> Value? {
        let hash = self.hash(forKey: key)
        for element in buckets[hash] {
            if element.key == key {
                return element.value
            }
        }
        return nil  /// Missing key in table
    }
    
    public func all() -> [(key: Key, value: Value)] {
        
        var dictionary = [Element]()
        for i in self.buckets {
            if !i.isEmpty {
                for j in i {
                    dictionary += [(key: j.key, value: j.value)]
                }
            }
        }
        return dictionary
    }
    
    private func resize() {
        if currentLoadFactor > maxLoadFactor {
            let oldDict = buckets
            buckets = Array<Bucket>(repeatElement([], count: size*2))
            for item in oldDict {
                for element in item {
                    updateValue(element.value,forKey: element.key, .resize)
                }
            }
        }
    }
    
    private func updateValue(_ value: Value, forKey key: Key, _ arg: Status = .none) {
        let hash = self.hash(forKey: key)
        
        if arg == .resize {
            buckets[hash].append((key: key, value: value))
        } else {
            for (i, element) in buckets[hash].enumerated() {
                if element.key == key {
                    _ = element.value
                    buckets[hash][i].value = value
                }
            }
        }
    }
    
    public func removeValue(forKey key: Key) -> Value? {
        let hash = self.hash(forKey: key)
        
        for (i, element) in buckets[hash].enumerated() {
            if element.key == key {
                buckets[hash].remove(at: i)
                count -= 1
                return element.value
            }
        }
        return nil  // key not in hash table
    }
    
    
    public func removeAll() {
        buckets = Array<Bucket>(repeatElement([], count: buckets.count))
        count = 0
    }
}


extension MyDictionary: CustomStringConvertible {
    
    public var description: String {
        
        let pairs = buckets.flatMap { b in b.map { e in "\(e.key): \(e.value)" } }
        return "[\(pairs.joined(separator: ", "))]"
    }
    
    public var debugDescription: String {
        var str = ""
        print("\n--> Debug Output <--")
        for (i, bucket) in buckets.enumerated() {
            let pairs = bucket.map { e in "\(e.key) = \(e.value)" }
            str += "bucket \(i): " + pairs.joined(separator: ", ") + "\n"
        }
        return str
    }
    
}


public class MySet<Value: Hashable> {
    
    private var buckets: [Value?]
    private var count: Int
    
    private let maxLoadFactor = 0.6
    public var currentLoadFactor: Double { return Double(count) / Double(size) }
    
    public var size: Int { buckets.count }
    
    public init(capacity: Int = 2) {
        self.buckets = [Value?](repeating: nil, count: capacity)
        self.count = 0
    }
    
    public convenience init() {
        self.init(capacity: 32)
    }
    
    private func hash(value: Value) -> Int {
        return abs(value.hashValue % buckets.count)
    }
    
    private func resize() {
        if currentLoadFactor > maxLoadFactor {
            let oldSet = self.buckets
            self.buckets = [Value?](repeating: nil, count: size*2)
            for member in oldSet.enumerated() {
                if let temp = member.element {
                    self.buckets[member.offset] = temp
                } else {
                    print("Missed value type")
                }
            }
        }
    }
    
    private func findFreeSpot(value: Value, hash: Int) {
        check: if (value == buckets[hash] && buckets[hash] != nil){
            break check
        } else {
            for i in buckets.enumerated() {
                if i.element == nil {
                    buckets[i.offset] = value
                    break
                }
            }
        }
    }
    
    public func contains(value: Value) -> Bool{
        return buckets.contains(value)
    }
    
    public func append(value: Value) {
        if !contains(value: value) {
            let hash = self.hash(value: value)
            findFreeSpot(value: value, hash: hash)
            //buckets[hash] = value
            count += 1
            resize()
        } else {
            print("Already contains!")
        }
    }
    
    public func all() -> [Value]{
        var resultArray = [Value]()
        for i in self.buckets {
            if let temp = i {
                resultArray.append(temp)
            }
        }
        print("\n---> Result array: ")
        return resultArray
    }
}




func myDict() {
    print("======== Class MyDictionary ========\n")
    let dict = MyDictionary<String, String>(capacity: 2)
    
    dict.append(key: "firstName1", value: "Surname1")
    print(dict.description)
    //print(dict.debugDescription) /// Debug output method, each bucket outputs separately
    
    dict.append(key: "firstName1", value: "Surname12")
    dict.append(key: "firstName2", value: "Surname2")
    dict.append(key: "firstName3", value: "Surname3")
    print(dict.description)
    //print(dict.debugDescription)

    
    dict.append(key: "nameMan", value: "Illia")
    dict.append(key: "nameWoman", value: "Stasy")
    print(dict.description)
    print(dict.debugDescription)
    
    print(dict.all())
}


func mySet() {
    print("\n\n\n\n======== Class MySet ========")
    let set = MySet<String>(capacity: 2)
    
    set.append(value: "num1")
    set.append(value: "num2")
    set.append(value: "num1")
    set.append(value: "num2")
    set.append(value: "num4")
    set.append(value: "num6")
    
    print("\n--- Call method 'contains':\n",
          set.contains(value: "num1"))
    print(set.contains(value: "num3"))
    
    print(set.all())
}

func main() {
    myDict()
    mySet()
}

main()
