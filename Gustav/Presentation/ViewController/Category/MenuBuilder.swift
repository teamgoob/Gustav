//
//  MenuBuilder.swift
//  Gustav
//
//  Created by 박선린 on 4/6/26.
//
import UIKit

struct MenuBuilder {

    static func makeAssociatedMenu(
        selectedid: UUID?,
        items: [Category],
        onSelect: @escaping (UUID?) -> Void
    ) -> UIMenu {
        
        var actions: [UIAction] = []

        actions.append(
            UIAction(
                title: "None",
                state: selectedid == nil ? .on : .off
            ) { _ in
                onSelect(nil)
            }
        )

        actions.append(contentsOf:
            items.map { item in
                UIAction(
                    title: item.name,
                    state: item.id == selectedid ? .on : .off
                ) { _ in
                    onSelect(item.id)
                    print("\(item.name) 선택됨")
                }
            }
        )
        
        return UIMenu(title: "Categoies", children: actions)
    }
}
