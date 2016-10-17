import UIKit
import OHHTTPStubs
import RealmSwift
import Fabric
import TwitterKit
import Keys

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var micropostId: String?
    var targetDate: String?
    var calendarCellWidth: CGFloat?
    var calendarCellHeight: CGFloat?
    let realm: Realm = try! Realm()
    let sunsetKeys = SunsetKeys()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        if (ProcessInfo.processInfo.arguments.contains("STUB_HTTP_ENDPOINTS")) {
            let formatter: DateFormatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"

            let fetchData: [Post] = realm.objects(Post.self).map{$0}
            for post in fetchData {
                try! realm.write() {
                    realm.delete(post)
                }
            }
            
            // 取ってくるやつに合わせる
            let suffix: String = "T99-99-99"
            
            stub(condition: isScheme("https") && isHost("asuforce.xyz") && isPath("/api/users/5") && isMethodGET()){ _ in
                return OHHTTPStubsResponse(
                    jsonObject: ["feeds" : [["content" : "Test Post", "created_at": formatter.string(from: Date()) + suffix, "id": 9999], ["content": "Apple", "created_at": formatter.string(from: Date().monthAgoDate()) + suffix, "id": 5]]],
                    statusCode: 200,
                    headers: nil
                )
            }
        }
        Twitter.sharedInstance().start(withConsumerKey: self.sunsetKeys.consumerKey(), consumerSecret: self.sunsetKeys.consumerSecret())
        Fabric.with([Twitter.self])
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
