import Foundation

extension String {
    
    subscript (i: Int) -> Character {
        let index = self.index(self.startIndex, offsetBy: i)
        return self.characters[index]
    }
    
    func substring(from: Int, to: Int) -> String {
        let fromIndex = self.index(self.startIndex, offsetBy: from)
        let toIndex = self.index(self.startIndex, offsetBy: to + 1)
        return self.substring(with: fromIndex ..< toIndex)
    }
}
