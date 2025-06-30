//
//  UIFont+USP.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 15/04/25.
//

import UIKit

extension UIFont {
    static func uspBold(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "UniversLTStd-Bold", size: size) ?? .boldSystemFont(ofSize: size)
    }

    static func uspRegular(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "UniversLTStd", size: size) ?? .systemFont(ofSize: size)
    }

    static func uspLight(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "UniversLTStd-Light", size: size) ?? .systemFont(ofSize: size, weight: .light)
    }

    static func uspBoldCaps(ofSize size: CGFloat) -> UIFont {
        let font = UIFont(name: "Univers-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
        let descriptor = font.fontDescriptor.withSymbolicTraits(.traitBold)?.withDesign(.default)
        return UIFont(descriptor: descriptor ?? font.fontDescriptor, size: size)
    }
}

extension UIFont {
    static func uspCaption(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "UniversLTStd-Light", size: size) ?? .systemFont(ofSize: size, weight: .light)
    }

    static func uspTitle(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "UniversLTStd-Bold", size: size) ?? .boldSystemFont(ofSize: size)
    }

    static func uspMono(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Courier", size: size) ?? .monospacedSystemFont(ofSize: size, weight: .regular)
    }
}
