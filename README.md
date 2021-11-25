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
3. Add library search paths.
   ![Screenshot 2021-11-25 at 11 27 41 AM](https://user-images.githubusercontent.com/87629483/143374716-0d76cb73-7655-40ce-89b9-feac873d8797.png)
 
   ``` "$(SDKROOT)/usr/lib/swift" ```
   
## Usage

    import DocumentScanner from 'react-native-ios-documentscanner';

    DocumentScanner().startScan(
          {
            savePath: { originalImagePath: 'temp/original', imagePath: 'temp/cropped' },
            callback: (image) => {
              console.log(image.originalImageList, image.imageList)
            }
          })

## FAQ
"$(SDKROOT)/usr/lib/swift\"
