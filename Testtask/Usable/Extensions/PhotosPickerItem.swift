//
//  PhotosPickerItem.swift
//  Testtask
//
//  Created by Miguel T on 18/09/24.
//

import SwiftUI
import PhotosUI

extension PhotosPickerItem {
    func getFilename() -> String {
        let errorStr = "Unknown"
        guard let assetId = self.itemIdentifier else { return errorStr }
        let fetchResult = PHAsset.fetchAssets(
            withLocalIdentifiers: [assetId],
            options: nil
        )
        guard let asset = fetchResult.firstObject else { return errorStr }
        let resources = PHAssetResource.assetResources(
            for: asset
        )
        guard let resource = resources.first else { return errorStr }
        return resource.originalFilename
    }
}
