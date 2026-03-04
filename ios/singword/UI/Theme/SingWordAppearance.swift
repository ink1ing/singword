import UIKit

enum SingWordAppearance {
    static func applyGlobalTypography() {
        let navTitleFont = preferredFont(name: "PlusJakartaSans-Regular", size: 18, weight: .semibold)
        let navLargeTitleFont = preferredFont(name: "PlusJakartaSans-Regular", size: 22, weight: .semibold)
        let bodyFont = preferredFont(name: "Inter-Regular", size: 14, weight: .regular)
        let tabFontNormal = preferredFont(name: "Inter-Regular", size: 12, weight: .medium)
        let tabFontSelected = preferredFont(name: "Inter-Regular", size: 12, weight: .semibold)
        let segmentFontNormal = preferredFont(name: "Inter-Regular", size: 13, weight: .medium)
        let segmentFontSelected = preferredFont(name: "Inter-Regular", size: 13, weight: .semibold)

        let navigationBar = UINavigationBar.appearance()
        navigationBar.titleTextAttributes = [.font: navTitleFont]
        navigationBar.largeTitleTextAttributes = [.font: navLargeTitleFont]

        let tabBarItem = UITabBarItem.appearance()
        tabBarItem.setTitleTextAttributes([.font: tabFontNormal], for: .normal)
        tabBarItem.setTitleTextAttributes([.font: tabFontSelected], for: .selected)

        let segmentedControl = UISegmentedControl.appearance()
        segmentedControl.setTitleTextAttributes([.font: segmentFontNormal], for: .normal)
        segmentedControl.setTitleTextAttributes([.font: segmentFontSelected], for: .selected)

        let barButton = UIBarButtonItem.appearance()
        barButton.setTitleTextAttributes([.font: bodyFont], for: .normal)
        barButton.setTitleTextAttributes([.font: bodyFont], for: .highlighted)
    }

    private static func preferredFont(name: String, size: CGFloat, weight: UIFont.Weight) -> UIFont {
        guard let customFont = UIFont(name: name, size: size) else {
            return .systemFont(ofSize: size, weight: weight)
        }

        let traits: [UIFontDescriptor.TraitKey: Any] = [.weight: weight]
        let descriptor = customFont.fontDescriptor.addingAttributes([.traits: traits])
        return UIFont(descriptor: descriptor, size: size)
    }
}
