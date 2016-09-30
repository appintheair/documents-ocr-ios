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
    
//    func test() -> String {
//        var result = self.characters.map({
//            switch char {
//            case "0": return "O"
//            case "1": return "I"
//            case "2": return "S"
//            case "3": return "S"
//            case "4": return "A"
//            case "5": return "S"
//            case "6": return "G"
//            case "7": return "Z"
//            case "8","9":
//                      return "B"
//                
//            default: return char
//        }
//        return String(self.characters)
//    }
    
    func replaceNumbers() -> String {
        var result = ""
        for char in self.characters {
            switch char {
            case "0": result.append("O")
            case "1": result.append("I")
            case "2": result.append("S")
            case "3": result.append("S")
            case "4": result.append("A")
            case "5": result.append("S")
            case "6": result.append("G")
            case "7": result.append("Z")
            case "8": result.append("B")
            case "9": result.append("B")
                
            default: result.append(char)
            }
        }
        
        return result
    }
    
    func replaceLetters() -> String {
        var result = ""
        for char in self.characters {
            switch char {
            case "O": result.append("0")
            case "I", "L":
                      result.append("1")
            case "S": result.append("5")
            case "A": result.append("4")
            case "G": result.append("6")
            case "Z": result.append("7")
            case "B": result.append("8")
                
            default: result.append(char)
            }
        }
        
        return result
    }
}
