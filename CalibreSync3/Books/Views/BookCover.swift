import SwiftUI
import Combine
import Macduff

struct BookCover: View {
    let title: String
    let fetchURL: URL
    
    var body: some View {
        ZStack(alignment: .init(horizontal: .center, vertical: .center)) {
//            ImageView(withURL: fetchURL)
//                .aspectRatio(contentMode: .fit)
            
//            Text(title)
//                .font(.title)
//                .foregroundColor(.white)
//                .opacity(0.5)
            
            RemoteImage(
                with: fetchURL,
                imageView: { Image(uiImage: $0).resizable() },
                loadingPlaceHolder: { ProgressView(progress: $0) },
                errorPlaceHolder: { ErrorView(error: $0) },
                config: Config(),
                completion: { (status) in
                    switch status {
                    case .success(let image): NSLog("success! imageSize: \(image.size)")
                    case .failure(let error): NSLog("failure... error: \(error.localizedDescription)")
                    }
                }
            ).frame(width: 100, height: 100*(4/3), alignment: .center)
            
        }
//        .overlay(
//            RoundedRectangle(cornerRadius: 16)
//                .strokeBorder(Color.white.opacity(0.3), lineWidth: 4)
//        )
//        .cornerRadius(16)
    }
    
    struct ProgressView: View {
        let progress: Float
        var body: some View {
            return GeometryReader { (geometry) in
                ZStack(alignment: .bottom) {
                    Rectangle().fill(Color.gray)
                    Rectangle().fill(Color.green)
                        .frame(width: nil, height: geometry.frame(in: .global).height * CGFloat(self.progress), alignment: .bottom)
                }
            }
        }
    }
    struct ErrorView: View {
        let error: Error
        var body: some View {
            ZStack {
                Rectangle().fill(Color.red)
                Text(error.localizedDescription).font(Font.system(size: 8))
            }
        }
    }
}

struct ImageView: View {
    @ObservedObject var imageLoader:ImageLoader2
    @State var image:UIImage = UIImage(imageLiteralResourceName: "11")
    
    init(withURL url:URL) {
        NSLog("init: \(url.path)")
        self.imageLoader = ImageLoader2(urlString:url)
    }
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width:100, height:100*(4/3))
            .padding(10)
            .onReceive(imageLoader.didChange) { data in
                self.image = UIImage(data: data) ?? UIImage()
            }
    }
}

class ImageLoader2: ObservableObject {
    var didChange = PassthroughSubject<Data, Never>()
    var task: URLSessionDataTask!
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }
    var fetchURL: URL
    
    init(urlString url:URL) {
        self.fetchURL = url
        run()
    }
    
    func run() {
        DispatchQueue.global(qos: .userInitiated).async {
//        DispatchQueue(label: "helloworld").async {
            self.task = URLSession.shared.dataTask(with: self.fetchURL) { data, response, error in
                guard let data = data else { return }
                DispatchQueue.main.async {
                    NSLog("downloaded")
                    self.data = data
                }
            }
            self.task.resume()
        }
    }
    
    deinit {
        task.cancel()
    }
}

#if DEBUG
struct BookCover_Previews: PreviewProvider {
    static var previews: some View {
        BookCover(title: "1", fetchURL: URL(string:"https://picsum.photos/120/140")!)
    }
}
#endif
