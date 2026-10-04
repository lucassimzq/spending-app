import CoreText
import SwiftUI
import UIKit

/// Fraunces (titles, money and the words you said) and Figtree (everything else).
///
/// Both ship as variable fonts. Their default instances are Fraunces 9pt Black and Figtree Light, so every font is
/// built with explicit axis values: weight, optical size, and Fraunces' Soft and Wonky axes. If the fonts are missing
/// the system serif and system font stand in.
enum KiraFont {
    private enum Axis {
        static let weight = 2_003_265_652       // 'wght'
        static let opticalSize = 1_869_640_570  // 'opsz'
        static let soft = 1_397_704_276         // 'SOFT'
        static let wonky = 1_464_815_179        // 'WONK'
    }

    private static let fraunces = "Fraunces-9ptBlack"
    private static let frauncesItalic = "Fraunces-9ptBlackItalic"
    private static let figtree = "Figtree-Light"
    private static let figtreeItalic = "Figtree-LightItalic"

    private static let cache = NSCache<NSString, UIFont>()

    static let isAvailable: Bool = UIFont(name: fraunces, size: 12) != nil && UIFont(name: figtree, size: 12) != nil

    /// Fraunces with the Soft axis fully on. `wonky` turns on its leaning letters, which titles use and numbers don't.
    static func display(size: CGFloat, weight: CGFloat = 620, italic: Bool = false, wonky: Bool = false) -> UIFont {
        let key = "display-\(size)-\(weight)-\(italic)-\(wonky)" as NSString
        if let cached = cache.object(forKey: key) { return cached }
        let font: UIFont
        if isAvailable {
            font = variable(italic ? frauncesItalic : fraunces, size: size, axes: [
                Axis.weight: weight,
                Axis.opticalSize: min(max(size, 9), 144),
                Axis.soft: 100,
                Axis.wonky: wonky ? 1 : 0,
            ])
        } else {
            font = system(size: size, weight: weight, italic: italic, design: .serif)
        }
        cache.setObject(font, forKey: key)
        return font
    }

    static func text(size: CGFloat, weight: CGFloat = 400, italic: Bool = false) -> UIFont {
        let key = "text-\(size)-\(weight)-\(italic)" as NSString
        if let cached = cache.object(forKey: key) { return cached }
        let font: UIFont
        if isAvailable {
            font = variable(italic ? figtreeItalic : figtree, size: size, axes: [Axis.weight: weight])
        } else {
            font = system(size: size, weight: weight, italic: italic, design: .default)
        }
        cache.setObject(font, forKey: key)
        return font
    }

    private static func variable(_ name: String, size: CGFloat, axes: [Int: CGFloat]) -> UIFont {
        let variations = UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String)
        let descriptor = UIFontDescriptor(fontAttributes: [.name: name, variations: axes])
        return UIFont(descriptor: descriptor, size: size)
    }

    private static func system(size: CGFloat, weight: CGFloat, italic: Bool, design: UIFontDescriptor.SystemDesign) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: uiWeight(weight))
        var descriptor = base.fontDescriptor.withDesign(design) ?? base.fontDescriptor
        if italic, let slanted = descriptor.withSymbolicTraits(.traitItalic) { descriptor = slanted }
        return UIFont(descriptor: descriptor, size: size)
    }

    private static func uiWeight(_ weight: CGFloat) -> UIFont.Weight {
        switch weight {
        case ..<250: return .thin
        case ..<350: return .light
        case ..<450: return .regular
        case ..<550: return .medium
        case ..<650: return .semibold
        case ..<750: return .bold
        case ..<850: return .heavy
        default: return .black
        }
    }
}

extension Font {
    static func fraunces(_ size: CGFloat, weight: CGFloat = 620, italic: Bool = false, wonky: Bool = false) -> Font {
        Font(KiraFont.display(size: size, weight: weight, italic: italic, wonky: wonky) as CTFont)
    }

    static func figtree(_ size: CGFloat, weight: CGFloat = 400, italic: Bool = false) -> Font {
        Font(KiraFont.text(size: size, weight: weight, italic: italic) as CTFont)
    }
}

/// Scales a Kira font with Dynamic Type, capped so the biggest numbers still fit on one line.
private struct ScaledKiraFont: ViewModifier {
    @ScaledMetric private var scale: CGFloat
    private let maximum: CGFloat
    private let make: (CGFloat) -> Font

    init(relativeTo style: Font.TextStyle, maximum: CGFloat, make: @escaping (CGFloat) -> Font) {
        _scale = ScaledMetric(wrappedValue: 1, relativeTo: style)
        self.maximum = maximum
        self.make = make
    }

    func body(content: Content) -> some View {
        content.font(make(min(scale, maximum)))
    }
}

extension View {
    /// Fraunces: titles, money and the words you said.
    func fraunces(_ size: CGFloat, weight: CGFloat = 620, italic: Bool = false, wonky: Bool = false,
                  relativeTo style: Font.TextStyle = .title, maximumScale: CGFloat = 1.4) -> some View {
        modifier(ScaledKiraFont(relativeTo: style, maximum: maximumScale) { scale in
            .fraunces(size * scale, weight: weight, italic: italic, wonky: wonky)
        })
    }

    /// Figtree: labels, lists and buttons. `digits` makes numbers line up in columns.
    func figtree(_ size: CGFloat, weight: CGFloat = 400, digits: Bool = false,
                 relativeTo style: Font.TextStyle = .body, maximumScale: CGFloat = 1.8) -> some View {
        modifier(ScaledKiraFont(relativeTo: style, maximum: maximumScale) { scale in
            let font = Font.figtree(size * scale, weight: weight)
            return digits ? font.monospacedDigit() : font
        })
    }
}
