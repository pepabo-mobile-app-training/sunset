import UIKit
import CoreData

class CalendarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    let dateAttributes: DateAttributes = DateAttributes()
    let dateManager: DateManager = DateManager()
    let daysPerWeek: Int = 7
    let cellMargin: CGFloat = -9.0
    var selectedDate: Date = Date()
    var today: Date!
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let TapCalendarCellNotification = Notification.Name("TapCelandarCell")

    @IBOutlet var swipeLeftGesture: UISwipeGestureRecognizer!
    @IBOutlet var swipeRightGesture: UISwipeGestureRecognizer!
    @IBOutlet weak var calendarCollectionView: UICollectionView!

    // [左へスワイプ] 1ヶ月進む
    @IBAction func swipedLeft(_ sender: UISwipeGestureRecognizer) {
        selectedDate = dateManager.nextMonth(selectedDate)
        calendarCollectionView.reloadData()
        // 月が変更する際にnavigationBarのタイトルも更新
        // navigationBarは親であるViewControllerが所持しているので、親の要素を書き換える
        self.parent?.title = changeHeaderTitle(selectedDate)
    }

    // [右へスワイプ] 1ヶ月戻る
    @IBAction func swipedRight(_ sender: UISwipeGestureRecognizer) {
        selectedDate = dateManager.prevMonth(selectedDate)
        calendarCollectionView.reloadData()
        // 月が変更する際にnavigationBarのタイトルも更新
        // navigationBarは親であるViewControllerが所持しているので、親の要素を書き換える
        self.parent?.title = changeHeaderTitle(selectedDate)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        calendarCollectionView.backgroundColor = UIColor.clear
        self.view.backgroundColor = UIColor.clear

        let TapPrevBtnNotification = Notification.Name("TapPrevBtn")
        let TapNextBtnNotification = Notification.Name("TapNextBtn")
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePrevView(_:)), name: TapPrevBtnNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateNextView(_:)), name: TapNextBtnNotification, object: nil)

        calendarCollectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dateManager.daysAcquisition() //ここは月によって異なる
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCell
        //テキストカラー
        if (indexPath.row % 7 == 0) {
            cell.textLabel.textColor = UIColor.red
        } else if (indexPath.row % 7 == 6) {
            cell.textLabel.textColor = UIColor.blue
        } else {
            cell.textLabel.textColor = UIColor.white
        }

        cell.textLabel.text = dateManager.conversionDateFormat(indexPath)
        if dateAttributes.isThisMonth(day: cell.textLabel.text!, row:indexPath.row) {
            if dateAttributes.existPosts(dayLabel: cell.textLabel.text!) {
                // 投稿があった日は太字 + 色を黒くする
                cell.textLabel.font = UIFont(name: "HiraKakuProN-W6", size: 11.5)
                cell.textLabel.textColor = UIColor.black
            }
        }

        return cell
    }

    //セルのサイズを設定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let length: CGFloat = (collectionView.frame.size.width) / CGFloat(daysPerWeek)

        appDelegate.calendarCellWidth = length
        appDelegate.calendarCellHeight = length

        return CGSize(width: length, height: length)
    }

    //セルの垂直方向のマージンを設定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellMargin
    }

    //セルの水平方向のマージンを設定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    // テキスト内のマージン設定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    // cellをtapした直後のアクション
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell : CalendarCell = collectionView.cellForItem(at: indexPath)! as! CalendarCell
        cell.circleImageView.image = UIImage(named: "circle")

        let day = dateManager.ShowDayIfInThisMonth(indexPath.row)
        if (day != "") {
            let year: String = (self.appDelegate.targetDate?.components(separatedBy: "-")[0])!
            let month: String = (self.appDelegate.targetDate?.components(separatedBy: "-")[1])!
            self.appDelegate.targetDate = year + "-" + month + "-" + day
        }

        NotificationCenter.default.post(name: TapCalendarCellNotification, object: nil)
    }

    // タップしたcellの前のcellに対するアクション
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell : CalendarCell = collectionView.cellForItem(at: indexPath)! as! CalendarCell
        cell.circleImageView.image = nil
    }

    //headerの月を変更
    func changeHeaderTitle(_ date: Date) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        let selectMonth = formatter.string(from: date)
        formatter.dateFormat = "yyyy-MM"
        let Month4Calc = formatter.string(from: date)
        updateTargetDate(date: Month4Calc)
        return selectMonth
    }

    // 月が変更する際に、appDelegate側の変数も更新する
    func updateTargetDate(date: String) {
        let day: String = (self.appDelegate.targetDate?.components(separatedBy: "-")[2])!
        appDelegate.targetDate = date + "-" + day
        NotificationCenter.default.post(name: TapCalendarCellNotification, object: nil)
    }

    @objc func updatePrevView(_ notification: Notification) {
        selectedDate = dateManager.prevMonth(selectedDate)
        self.parent?.title = changeHeaderTitle(selectedDate)
        calendarCollectionView.reloadData()
    }

    @objc func updateNextView(_ notification: Notification) {
        selectedDate = dateManager.nextMonth(selectedDate)
        self.parent?.title = changeHeaderTitle(selectedDate)
        calendarCollectionView.reloadData()
    }
}
