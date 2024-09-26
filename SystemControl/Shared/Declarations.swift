//
//  Declarations.swift
// Bridge Score
//
//  Created by Marc Shearer on 01/02/2021.
//

import CoreGraphics
import SwiftUI

// Parameters

public let maxRetention = 366
public let appGroup = "group.com.sheareronline.bridgescore" // Has to match entitlements
public let widgetKind = "com.sheareronline.bridgescore"

// Sizes

var inputTopHeight: CGFloat { MyApp.format != .phone ? 20.0 : 10.0 }
let inputDefaultHeight: CGFloat = 30.0
var inputToggleDefaultHeight: CGFloat { MyApp.format != .phone ? 30.0 : 16.0 }
var bannerHeight: CGFloat { isLandscape ? (MyApp.format != .phone ? 60.0 : 50.0)
                                        : (MyApp.format != .phone ? 60.0 : 40.0) }
var alternateBannerHeight: CGFloat { MyApp.format != .phone ? 50.0 : 35.0 }
var minimumBannerHeight: CGFloat { MyApp.format != .phone ? 40.0 : 20.0 }
var bannerBottom: CGFloat { (MyApp.format != .phone ? 30.0 : (isLandscape ? 5.0 : 10.0)) }
var slideInMenuRowHeight: CGFloat { MyApp.target == .iOS ? 50 : 40 }

// Fonts (Font)
var bannerFont: Font { Font.system(size: (MyApp.format != .phone ? 32.0 : 24.0)) }
var alternateBannerFont: Font { Font.system(size: (MyApp.format != .phone ? 20.0 : 18.0)) }
var defaultFont: Font { Font.system(size: (MyApp.format != .phone ? 28.0 : 24.0)) }
var toolbarFont: Font { Font.system(size: (MyApp.format != .phone ? 16.0 : 14.0)) }
var captionFont: Font { Font.system(size: (MyApp.format != .phone ? 20.0 : 18.0)) }
var inputTitleFont: Font { Font.system(size: (MyApp.format != .phone ? 20.0 : 18.0)) }
var inputFont: Font { Font.system(size: (MyApp.format != .phone ? 16.0 : 14.0)) }
var messageFont: Font { Font.system(size: (MyApp.format != .phone ? 16.0 : 14.0)) }
var searchFont: Font { Font.system(size: (MyApp.format != .phone ? 20.0 : 16.0)) }
var smallFont: Font { Font.system(size: (MyApp.format != .phone ? 14.0 : 12.0)) }
var tinyFont: Font { Font.system(size: (MyApp.format != .phone ? 12.0 : 8.0)) }
var responsibleTitleFont: Font {  Font.system(size: (MyApp.format != .phone ? 30.0 : 18.0)) }
var responsibleCaptionFont: Font {  Font.system(size: (MyApp.format != .phone ? 12.0 : 8.0)) }

// Fonts in scorecard (UIFont)
var titleFont: UIFont {  UIFont.systemFont(ofSize: (MyApp.format != .phone ? 16.0 : 10.0)) }
var titleCaptionFont: UIFont { UIFont.systemFont(ofSize: (MyApp.format != .phone ? 16.0 : 10.0)) }
var cellFont: UIFont {  UIFont.systemFont(ofSize: (MyApp.format != .phone ? 28.0 : 16.0)) }
var boardFont: UIFont {  UIFont.systemFont(ofSize: (MyApp.format != .phone ? 28.0 : 18.0)) }
var boardTitleFont: UIFont {  UIFont.systemFont(ofSize: (MyApp.format != .phone ? 28.0 : 14.0)) }
var pickerTitleFont: UIFont {  UIFont.systemFont(ofSize: (MyApp.format != .phone ? 30.0 : 18.0)) }
var pickerCaptionFont: UIFont {  UIFont.systemFont(ofSize: (MyApp.format != .phone ? 12.0 : 8.0)) }
var windowTitleFont: UIFont {  UIFont.systemFont(ofSize: (MyApp.format != .phone ? 30.0 : 20.0)) }
var sectionTitleFont: UIFont {  UIFont.systemFont(ofSize: (MyApp.format != .phone ? 24.0 : 16.0)) } 
var smallCellFont: UIFont {  UIFont.systemFont(ofSize: (MyApp.format != .phone ? 22.0 : 12.0)) }
var tinyCellFont: UIFont {  UIFont.systemFont(ofSize: (MyApp.format != .phone ? 8.0 : 6.0)) }
var replaceFont: UIFont {  UIFont.systemFont(ofSize: (MyApp.format != .phone ? 30.0 : 20.0)) }
var replaceTitleFont: UIFont {  UIFont.systemFont(ofSize: (MyApp.format != .phone ? 30.0 : 20.0)) }
var analysisFont: UIFont { UIFont.systemFont(ofSize: (MyApp.format != .phone ? 16.0 : 12.0)) }

// Slide in IDs - Need to be declared here as there seem to be multiple instances of views
let scorecardListViewId = UUID()
let scorecardInputViewId = UUID()
let scorecardDetailViewId = UUID()
let layoutSetupViewId = UUID()
let statsViewId = UUID()

// iCloud database identifier
let iCloudIdentifier = "iCloud.MarcShearer.BridgeScore"

// Columns for record IDs
let recordIdKeys: [String:[String]] = [:]

// Backups
let backupDirectoryDateFormat = "yyyy-MM-dd-HH-mm-ss-SSS"
let backupDateFormat = "yyyy-MM-dd HH:mm:ss.SSS Z"
let recordIdDateFormat = "yyyy-MM-dd-HH-mm-ss"

// Other constants
let tagMultiplier = 1000000
let nullUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
let useBboHandViewer = false

// Localisable names

public let appName = "Bridge Scorecard"
public let appImage = "bridge score"

public let dateFormat = "EEEE d MMMM yyyy"

public enum UIMode {
    case uiKit
    case appKit
    case unknown
}

public var isLandscape: Bool {
    UIScreen.main.bounds.width > UIScreen.main.bounds.height
}

#if canImport(UIKit)
public let target: UIMode = .uiKit
#elseif canImport(appKit)
public let target: UIMode = .appKit
#else
public let target: UIMode = .unknow
#endif
