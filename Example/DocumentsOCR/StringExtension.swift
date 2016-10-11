import Foundation

extension String {
    
    subscript (i: Int) -> Character {
        let index = self.startIndex.advancedBy(i)
        return self.characters[index]
    }
    
    func substring(from: Int, to: Int) -> String {
        let fromIndex = self.startIndex.advancedBy(from)
        let toIndex = self.startIndex.advancedBy(to + 1)
        return self.substringWithRange(fromIndex ..< toIndex)
    }
}
