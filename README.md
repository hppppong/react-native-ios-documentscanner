# React-Native-iOS-DocumentScanner
iOS document scanner for React Native (using VisionKit).

## Installation

1. Install React Native iOS DocumentScanner.
    ```bash
    npm install react-native-ios-documentscanner --save
    ```
2. Run Pod install.
    ```bash
    cd ios
    pod install
    ``` 
    
## Usage

    import DocumentScanner from 'react-native-ios-documentscanner';

    DocumentScanner().startScan(
          {
            savePath: { originalImagePath: 'temp/original', imagePath: 'temp/cropped' },
            callback: (image) => {
              console.log(image.originalImageList, image.imageList)
            }
          })
