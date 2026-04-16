//
//  TagColorCell.swift
//  Gustav
//
//  Created by 박선린 on 3/25/26.
//

import UIKit
import SnapKit

class TagColorCell: UICollectionViewCell {
    static let reuseID = "TagColorCell"
    
    private let circleImage = UIImageView()
//    = {
//        let view = UIImageView()
//        view.image = UIImage(systemName: "circle")
//        return view)
//    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        self.backgroundColor = Colors.Theme.mainBackground
        
        self.contentView.addSubview(circleImage)
        circleImage.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
        
    }
    
    func configure(cellColor: TagColor, isSelected: Bool) {
        let imageName = isSelected ? "circle.fill" : "circle"
        circleImage.image = UIImage(systemName: imageName)
        circleImage.tintColor = cellColor.uiColor
    }
}
