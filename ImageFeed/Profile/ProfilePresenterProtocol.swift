protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewProtocol? { get set }
    func viewDidLoad()
    func didTapLogout()
    func confirmLogout()
}
