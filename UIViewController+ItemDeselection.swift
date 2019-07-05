//
//  SizeClasses
//
//  Created by Hedi BEN JAHOUACH on 05/01/2019.
//  Copyright © 2019 BenJ.Hedi. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    public func deselectRowUsingTransitionCoordinator(in tableView: UITableView) {
        // Get the initially selected index paths, if any
        let selectedIndexPaths = tableView.indexPathsForSelectedRows ?? []

        // Grab the transition coordinator responsible for the current transition
        if let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: { context in
                selectedIndexPaths.forEach {
                    tableView.deselectRow(at: $0, animated: context.isAnimated)
                }
            })
        }
        else { // If this isn't a transition coordinator, just deselect the rows without animating
            selectedIndexPaths.forEach {
                tableView.deselectRow(at: $0, animated: false)
            }
        }
    }

    public func deselectItemUsingTransitionCoordinator(in collectionView: UICollectionView) {
        // Get the initially selected index paths, if any
        let selectedIndexPaths = collectionView.indexPathsForSelectedItems ?? []

        // Grab the transition coordinator responsible for the current transition
        if let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: { context in
                selectedIndexPaths.forEach {
                    collectionView.deselectItem(at: $0, animated: context.isAnimated)
                }
            })
        }
        else { // If this isn't a transition coordinator, just deselect the rows without animating
            selectedIndexPaths.forEach {
                collectionView.deselectItem(at: $0, animated: false)
            }
        }
    }
}
