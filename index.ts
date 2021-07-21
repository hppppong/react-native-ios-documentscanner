import { NativeModules } from 'react-native'

interface IDocumentScanner {
  startScan: (param: IScanParam) => void
  detectRectangle: (param: IDetectParam) => void
  dismiss: () => void
}

interface IScanParam {
  savePath: ISavePath,
  callback: (image: IScanCallback) => void
}

interface IScanCallback {
  originalImageList: [String],
  imageList: [String]
}

interface ISavePath {
  originalImagePath: String,
  imagePath: String
}

interface IDetectParam {
  path: String,
  callback: (boundingBox: [Object]) => void
}

const DocumentScanner = () => {

  const documentScanner = NativeModules.RNDocumentScanner

  return {
    startScan: (param: IScanParam) => {
      documentScanner.startScan(param.savePath, param.callback)
    },
    detectRectangle: (param: IDetectParam) => {
      documentScanner.detectRectangle(param.path, param.callback)
    },
    dismiss: () => {
      documentScanner.dismiss()
    },
  }
}

export default DocumentScanner