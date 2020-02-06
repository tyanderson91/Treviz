import Cocoa
import Foundation

@testable import TrajectoryAnalysis
var str = "Hello, playground"

let newCond = Condition()
let condData = NSKeyedArchiver.archivedData(withRootObject: newCond, requiringSecureCoding: false)
let oldCond = NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(condData) as! Condition

oldCond === newCond
