/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

protocol MenuConfiguration {

    var menuItems: [MenuItem] { get }
    var menuToolbarItems: [MenuToolbarItem]? { get }
    var numberOfItemsInRow: Int { get }

    init(appState: AppState)
    func toolbarColour() -> UIColor
    func toolbarTintColor() -> UIColor
    func menuBackgroundColor() -> UIColor
    func menuTintColor() -> UIColor
    func menuFont() -> UIFont
    func menuIcon() -> UIImage?
    func shadowColor() -> UIColor
    func selectedItemTintColor() -> UIColor
}


protocol MenuActionDelegate: class {
    func performMenuAction(action: MenuAction, withAppState appState: AppState)
}

enum MenuAction {
    case OpenNewNormalTab
    @available(iOS 9, *) case OpenNewPrivateTab
    case FindInPage
    @available(iOS 9, *) case ToggleBrowsingMode
    case ToggleBookmarkStatus
    case OpenSettings
    case CloseAllTabs
    case OpenTopSites
    case OpenBookmarks
    case OpenHistory
    case OpenReadingList
}

struct FirefoxMenuConfiguration: MenuConfiguration {

    internal private(set) var menuItems = [MenuItem]()
    internal private(set) var menuToolbarItems: [MenuToolbarItem]?
    internal private(set) var numberOfItemsInRow: Int = 0

    private(set) var isPrivateMode: Bool = false

    init(appState: AppState) {
        menuItems = menuItemsForAppState(appState)
        menuToolbarItems = menuToolbarItemsForAppState(appState)
        numberOfItemsInRow = numberOfMenuItemsPerRowForAppState(appState)
        isPrivateMode = appState.isPrivate()
    }

    func toolbarColour() -> UIColor {

        return isPrivateMode ? UIConstants.MenuToolbarBackgroundColorPrivate : UIConstants.MenuToolbarBackgroundColorNormal
    }

    func toolbarTintColor() -> UIColor {
        return isPrivateMode ? UIConstants.MenuToolbarTintColorPrivate : UIConstants.MenuToolbarTintColorNormal
    }

    func menuBackgroundColor() -> UIColor {
        return isPrivateMode ? UIConstants.MenuBackgroundColorPrivate : UIConstants.MenuBackgroundColorNormal
    }

    func menuTintColor() -> UIColor {
        return isPrivateMode ? UIConstants.MenuToolbarTintColorPrivate : UIConstants.MenuBackgroundColorPrivate
    }

    func menuFont() -> UIFont {
        return UIFont.systemFontOfSize(11)
    }

    func menuIcon() -> UIImage? {
        return isPrivateMode ? UIImage(named:"bottomNav-menu-pbm") : UIImage(named:"bottomNav-menu")
    }

    func shadowColor() -> UIColor {
        return isPrivateMode ? UIColor.darkGrayColor() : UIColor.lightGrayColor()
    }

    func selectedItemTintColor() -> UIColor {
        return UIConstants.MenuSelectedItemTintColor
    }

    private func numberOfMenuItemsPerRowForAppState(appState: AppState) -> Int {
        switch appState {
        case .TabTray:
            return 4
        default:
            return 3
        }
    }

    // the items should be added to the array according to desired display order
    private func menuItemsForAppState(appState: AppState) -> [MenuItem] {
        var menuItems = [MenuItem]()
        switch appState {
        case .Tab(let tabState):
            menuItems.append(FirefoxMenuConfiguration.FindInPageMenuItem)
            if #available(iOS 9, *) {
                menuItems.append(tabState.desktopSite ? FirefoxMenuConfiguration.RequestMobileMenuItem : FirefoxMenuConfiguration.RequestDesktopMenuItem)
            }
            menuItems.append(FirefoxMenuConfiguration.SettingsMenuItem)
            menuItems.append(FirefoxMenuConfiguration.NewTabMenuItem)
            if #available(iOS 9, *) {
                menuItems.append(FirefoxMenuConfiguration.NewPrivateTabMenuItem)
            }
            menuItems.append(tabState.isBookmarked ? FirefoxMenuConfiguration.RemoveBookmarkMenuItem : FirefoxMenuConfiguration.AddBookmarkMenuItem)
        case .HomePanels:
            menuItems.append(FirefoxMenuConfiguration.NewTabMenuItem)
            if #available(iOS 9, *) {
                menuItems.append(FirefoxMenuConfiguration.NewPrivateTabMenuItem)
            }
            menuItems.append(FirefoxMenuConfiguration.SettingsMenuItem)
        case .TabTray:
            menuItems.append(FirefoxMenuConfiguration.NewTabMenuItem)
            if #available(iOS 9, *) {
                menuItems.append(FirefoxMenuConfiguration.NewPrivateTabMenuItem)
            }
            menuItems.append(FirefoxMenuConfiguration.CloseAllTabsMenuItem)
            menuItems.append(FirefoxMenuConfiguration.SettingsMenuItem)
        default:
            menuItems = []
        }
        return menuItems
    }

    // the items should be added to the array according to desired display order
    private func menuToolbarItemsForAppState(appState: AppState) -> [MenuToolbarItem]? {
        let menuToolbarItems: [MenuToolbarItem]?
        switch appState {
        case .Tab, .TabTray:
            menuToolbarItems = [FirefoxMenuConfiguration.TopSitesMenuToolbarItem,
                                FirefoxMenuConfiguration.BookmarksMenuToolbarItem,
                                FirefoxMenuConfiguration.HistoryMenuToolbarItem,
                                FirefoxMenuConfiguration.ReadingListMenuToolbarItem]
        default:
            menuToolbarItems = nil
        }
        return menuToolbarItems
    }
}

// MARK: Static helper access function

extension FirefoxMenuConfiguration {

    private static var NewTabMenuItem: MenuItem {
        return FirefoxMenuItem(title: NewTabTitleString, action: .OpenNewNormalTab, icon: "menu-NewTab", privateModeIcon: "menu-NewTab-pbm")
    }

    @available(iOS 9, *)
    private static var NewPrivateTabMenuItem: MenuItem {
        return FirefoxMenuItem(title: NewPrivateTabTitleString, action: .OpenNewPrivateTab, icon: "menu-NewPrivateTab", privateModeIcon: "menu-NewPrivateTab-pbm")
    }

    private static var AddBookmarkMenuItem: MenuItem {
        return FirefoxMenuItem(title: AddBookmarkTitleString, action: .ToggleBookmarkStatus, icon: "menu-Bookmark", privateModeIcon: "menu-Bookmark-pbm", selectedIcon: "menu-RemoveBookmark", animation: JumpAndSpinAnimator())
    }

    private static var RemoveBookmarkMenuItem: MenuItem {
        return FirefoxMenuItem(title: RemoveBookmarkTitleString, action: .ToggleBookmarkStatus, icon: "menu-RemoveBookmark", privateModeIcon: "menu-RemoveBookmark")
    }

    private static var FindInPageMenuItem: MenuItem {
        return FirefoxMenuItem(title: FindInPageTitleString, action: .FindInPage, icon: "menu-FindInPage", privateModeIcon: "menu-FindInPage-pbm")
    }

    @available(iOS 9, *)
    private static var RequestDesktopMenuItem: MenuItem {
        return FirefoxMenuItem(title: ViewDesktopSiteTitleString, action: .ToggleBrowsingMode, icon: "menu-RequestDesktopSite", privateModeIcon: "menu-RequestDesktopSite-pbm")
    }

    @available(iOS 9, *)
    private static var RequestMobileMenuItem: MenuItem {
        return FirefoxMenuItem(title: ViewMobileSiteTitleString, action: .ToggleBrowsingMode, icon: "menu-ViewMobile", privateModeIcon: "menu-ViewMobile-pbm")
    }

    private static var SettingsMenuItem: MenuItem {
        return FirefoxMenuItem(title: SettingsTitleString, action: .OpenSettings, icon: "menu-Settings", privateModeIcon: "menu-Settings-pbm")
    }

    private static var CloseAllTabsMenuItem: MenuItem {
        return FirefoxMenuItem(title: CloseAllTabsTitleString, action: .CloseAllTabs, icon: "menu-CloseTabs", privateModeIcon: "menu-CloseTabs-pbm")
    }

    private static var TopSitesMenuToolbarItem: MenuToolbarItem {
        return FirefoxMenuToolbarItem(title: TopSitesTitleString, action: .OpenTopSites, icon: "menu-panel-TopSites")
    }

    private static var BookmarksMenuToolbarItem: MenuToolbarItem {
        return FirefoxMenuToolbarItem(title: BookmarksTitleString, action: .OpenBookmarks, icon: "menu-panel-Bookmarks")
    }

    private static var HistoryMenuToolbarItem: MenuToolbarItem {
        return FirefoxMenuToolbarItem(title: HistoryTitleString, action: .OpenHistory, icon: "menu-panel-History")
    }

    private static var ReadingListMenuToolbarItem: MenuToolbarItem {
        return  FirefoxMenuToolbarItem(title: ReadingListTitleString, action: .OpenReadingList, icon: "menu-panel-ReadingList")
    }

    static let NewTabTitleString = NSLocalizedString("New Tab", tableName: "Menu", comment: "String describing the action of creating a new tab from the menu")
    static let NewPrivateTabTitleString = NSLocalizedString("New Private Tab", tableName: "Menu", comment: "String describing the action of creating a new private tab from the menu")
    static let AddBookmarkTitleString = NSLocalizedString("Add Bookmark", tableName: "Menu", comment: "String describing the action of adding the current site as a bookmark from the menu")
    static let RemoveBookmarkTitleString = NSLocalizedString("Remove Bookmark", tableName: "Menu", comment: "String describing the action of remove the current site as a bookmark from the menu")
    static let FindInPageTitleString = NSLocalizedString("Find In Page", tableName: "Menu", comment: "String describing the action of opening the toolbar that allows users to search for items within a webpage from the menu")
    static let ViewDesktopSiteTitleString = NSLocalizedString("View Desktop Site", tableName: "Menu", comment: "String describing the action of switching a website from a mobile optimized view to a desktop view from the menu")
    static let ViewMobileSiteTitleString = NSLocalizedString("View Mobile Site", tableName: "Menu", comment: "String describing the action of switching a website from a desktop view to a mobile optimized view from the menu")
    static let SettingsTitleString = NSLocalizedString("Settings", tableName: "Menu", comment: "String describing the action of opening the settings menu from the menu")
    static let CloseAllTabsTitleString = NSLocalizedString("Close All Tabs", tableName: "Menu", comment: "String describing the action of closing all tabs in the tab tray at once from the menu")
    static let TopSitesTitleString = NSLocalizedString("Top Sites", tableName: "Menu", comment: "String describing the action of opening the Top Sites home panel from the menu")
    static let BookmarksTitleString = NSLocalizedString("Bookmarks", tableName: "Menu", comment: "String describing the action of opening the bookmarks home panel from the menu")
    static let HistoryTitleString = NSLocalizedString("History", tableName: "Menu", comment: "String describing the action of opening the history home panel from the menu")
    static let ReadingListTitleString = NSLocalizedString("Reading List", tableName: "Menu", comment: "String describing the action of opening the reading list home panel from the menu")
}
