import UIKit
import CoreData

class DateAttributes {
    
    // その日に投稿があったか
    func existPosts(dayLabel: String) -> Bool {
        var day: String = dayLabel
        // 1桁の場合、接頭辞として'0'を付与
        if dayLabel.characters.count == 1 {
            day = "0" + dayLabel
        }
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
        
        let year: String = (appDelegate.targetDate?.components(separatedBy: "-")[0])!
        let month: String = (appDelegate.targetDate?.components(separatedBy: "-")[1])!
        let date: String = year + "-" + month + "-" + day
        let predicate: NSPredicate = NSPredicate(format: "created_at BEGINSWITH %@", date)
        fetchRequest.predicate = predicate
        
        let fetchData = try! managedObjectContext.fetch(fetchRequest)
        if fetchData.count == 0 {
            return false
        } else {
            return true
        }
    }

    // 曜日の色の振り分け
    func choiceDaysColor(row: Int) -> UIColor {
        switch (row % 7) {
        case 0:
            return UIColor.red
        case 6:
            return UIColor.blue
        default:
            return UIColor.white
        }
    }
}
