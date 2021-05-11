    //
    //  ColorMap.swift
    //  Treviz
    //
    //  Created by Tyler Anderson on 3/14/21.
    //  Copyright © 2021 Tyler Anderson. All rights reserved.
    //

    import Foundation

    extension CGColor {
        static let teal = CGColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
        static let magenta = CGColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0)
        static let yellow = CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
        static let blue = CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        static let red = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        static let green = CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
    }

    extension Array where Element == CGFloat {
        func interpolate(pct: CGFloat)->CGFloat? {
            if pct<=0.0 { return self.first }
            else if pct>=1.0 { return self.last }
            let pcts = (0...self.count-1).map({ CGFloat($0) / CGFloat(self.count-1) })
            guard let base_index = pcts.lastIndex(where: {$0 <= pct} ) else { return nil}
            
            let v1 = self[base_index]
            let v2 = self[base_index+1]-self[base_index]
            let v3 = pcts[base_index+1]-pcts[base_index]
            let v4 = pct-pcts[base_index]
            let newVal: CGFloat = v1+v2/v3*v4
            return newVal
        }
    }

    class ColorMap: Decodable {
        var name: String
        var isContinuous: Bool = false
        var colors: [CGColor]
        var reds: [CGFloat]!
        var greens: [CGFloat]!
        var blues: [CGFloat]!

        init(name nameIn: String, colors colorsIn: [CGColor]) {
            colors = colorsIn
            name = nameIn
            setComponents()
        }

        init(name nameIn: String, isContinuous contIn: Bool, rgbComponents compsIn: [[CGFloat]]){
            name = nameIn
            isContinuous = contIn
            
            colors = Array(repeating: CGColor.black, count: compsIn.count)
            var i = 0
            for thisComp in compsIn {
                assert(thisComp.count == 3)
                let newColor = CGColor(red: thisComp[0], green: thisComp[1], blue: thisComp[2], alpha: 1.0)
                colors[i] = newColor
                i += 1
            }
            setComponents()
        }
        
        private func setComponents(){
            reds = colors.map({$0.components?[0] ?? 0.0})
            greens = colors.map({$0.components?[1] ?? 0.0})
            blues = colors.map({$0.components?[2] ?? 0.0})
        }
        
        subscript(index: Int)->CGColor?{
            get {
                guard !isContinuous && index<colors.count else { return nil }
                return colors[index]
            }
        }
        subscript(pct: Float)->CGColor?{
            get {
                guard pct<=1.0 && pct>=0.0 else { return nil }
                let cgPct = CGFloat(pct)
                let newRed = reds.interpolate(pct: cgPct) ?? 0.0
                let newGreen = greens.interpolate(pct: cgPct) ?? 0.0
                let newBlue = blues.interpolate(pct: cgPct) ?? 0.0
                return CGColor(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
            }
        }
        subscript(index: Int, total: Int)->CGColor?{
            if isContinuous {
                let colorPct: Float = Float(index)/Float(total-1)
                return self[colorPct] ?? CGColor.black
            } else {
                let color_index = index % (colors.count)
                return self[color_index]!
            }
        }
        
        
        // MARK: Codable
        enum CodingKeys: CodingKey {
            case name
            case continuous
            case colors
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            try name = container.decode(String.self, forKey: .name)
            try isContinuous = container.decode(Bool.self, forKey: .continuous)
            let colorComponents = try container.decode(Array<Array<CGFloat>>.self, forKey: .colors)
            colors = colorComponents.compactMap { CGColor(red: $0[0], green: $0[1], blue: $0[2], alpha: 1.0)}
            setComponents()
        }
        
        static let defaultMap = ColorMap(name: "greyscale", isContinuous: false, rgbComponents: [
            [0.0, 0.0, 0.0],
            [0.3,0.3, 0.3],
            [0.6, 0.6, 0.6],
            [0.9, 0.9, 0.9]
        ])
        
        static var allMaps: [ColorMap] = [defaultMap]
    }
