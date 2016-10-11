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
    
    func replaceNumbers() -> String {
        var result = ""
        for char in self.characters {
            switch char {
            case "0":
                result.appendContentsOf("O")
                break;
            case "1":
                result.appendContentsOf("I")
                break;
            case "2":
                result.appendContentsOf("S")
                break;
            case "3":
                result.appendContentsOf("S")
                break;
            case "4":
                result.appendContentsOf("A")
                break;
            case "5":
                result.appendContentsOf("S")
                break;
            case "6":
                result.appendContentsOf("G")
                break;
            case "7":
                result.appendContentsOf("Z")
                break;
            case "8",
                 "9":
                result.appendContentsOf("B")
                break;
                
            default:
                result.append(char)
            }
        }
        
        return result
    }
    
    func replaceLetters() -> String {
        var result = ""
        for char in self.characters {
            switch char {
            case "O",
                 "D":
                result.appendContentsOf("0")
                break;
                
            case "I",
                 "L":
                result.appendContentsOf("1")
                break;
                
            case "S":
                result.appendContentsOf("5")
                break;
                
            case "A":
                result.appendContentsOf("4")
                break;
                
            case "G":
                result.appendContentsOf("6")
                break;
                
            case "Z":
                result.appendContentsOf("7")
                break;
                
            case "B":
                result.appendContentsOf("8")
                break;
                
            default: result.append(char)
            }
        }
        
        return result
    }
}
