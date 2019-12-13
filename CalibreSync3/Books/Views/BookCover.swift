import SwiftUI
import Combine
import Macduff
import URLImage

let BOOK_WIDTH:CGFloat = 115.0
let BOOK_HEIGHT = BOOK_WIDTH * (4/3)

struct BookCover: View {
    let title: String
    let fetchURL: URL
    
    var body: some View {
        ZStack() {
//            ImageView(withURL: fetchURL)
//                .aspectRatio(contentMode: .fit)

            VStack {
                if(fetchURL.scheme == "https") {
                    Image("cover")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: BOOK_WIDTH, height: BOOK_HEIGHT, alignment: .center)
                } else {
                
                    URLImage(fetchURL,
                             delay: 0,
                             processors:[  Resize(size: CGSize(width: BOOK_WIDTH, height: BOOK_HEIGHT), scale: UIScreen.main.scale) ],
                             content: {
                                $0.image
                                    .resizable()                     // Make image resizable
                                    .aspectRatio(contentMode: .fit) // Fill the frame
                                })
                        .frame(width: BOOK_WIDTH, height: BOOK_HEIGHT)
                    
//                    RemoteImage(
//                        with: fetchURL,
//                        imageView: { Image(uiImage: $0).resizable() },
//                        loadingPlaceHolder: { ProgressView(progress: $0) },
//                        errorPlaceHolder: { ErrorView(error: $0) },
//                        config: Config(),
//                        completion: { (status) in
//                            switch status {
//                            case .success(let image): NSLog("success! imageSize: \(image.size)")
//                            case .failure(let error): NSLog("failure... error: \(error.localizedDescription)")
//                            }
//                        }
//                    ).frame(width: BOOK_WIDTH, height: BOOK_HEIGHT)
                }
            }
            
            DownloadView()
        }
//        .overlay(
//            RoundedRectangle(cornerRadius: 16)
//                .strokeBorder(Color.white.opacity(0.3), lineWidth: 4)
//        )
//        .cornerRadius(16)
    }
    
    struct DownloadView: View {
        var downloaded = false
        
        var body: some View {
            VStack {
                Spacer()
                
                ZStack {
                    Rectangle()
                        .frame(width: BOOK_WIDTH, height:20, alignment:.bottom)
                        .background(Color.black)
                        .opacity(0.1)
                    
                    HStack {
                        Spacer()
                        
                        Image(systemName: self.downloaded ? "cloud.fill" : "cloud")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width:BOOK_WIDTH/5, height:BOOK_HEIGHT/6)
                            .font(.system(size: 50))
                            .foregroundColor(.yellow)
                            .opacity(1)
                        //    .offset(x:BOOK_WIDTH/2 - 10, y:BOOK_HEIGHT/2 - 10)
                    }
                }
            }.frame(width: BOOK_WIDTH, height: BOOK_HEIGHT, alignment: .bottom)
        }
    }
    
    struct ProgressView: View {
        let progress: Float
        private let kPreviewBackground = Color(red: 244/255.0, green: 236/255.0, blue: 230/255.0)
        var body: some View {
            ZStack {
                kPreviewBackground
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    ActivityIndicator()
                        .frame(width: 50, height: 50)
                }.foregroundColor(Color.white)
            }
        }
//        var body: some View {
//            return GeometryReader { (geometry) in
//                ZStack(alignment: .bottom) {
//                    Rectangle().fill(Color.gray)
//                    Rectangle().fill(Color.green)
//                        .frame(width: nil, height: geometry.frame(in: .global).height * CGFloat(self.progress), alignment: .bottom)
//                }
//            }
//        }
//
    }
    
    struct ActivityIndicator: View {
        @State private var isAnimating: Bool = false
        
        var body: some View {
            GeometryReader { (geometry: GeometryProxy) in
                ForEach(0..<5) { index in
                    Group {
                        Circle()
                            .frame(width: geometry.size.width / 5, height: geometry.size.height / 5)
                            .scaleEffect(!self.isAnimating ? 1 - CGFloat(index) / 5 : 0.2 + CGFloat(index) / 5)
                            .offset(y: geometry.size.width / 10 - geometry.size.height / 2)
                    }.frame(width: geometry.size.width, height: geometry.size.height)
                        .rotationEffect(!self.isAnimating ? .degrees(0) : .degrees(360))
                        .animation(Animation
                            .timingCurve(0.5, 0.15 + Double(index) / 5, 0.25, 1, duration: 1.5)
                            .repeatForever(autoreverses: false))
                }
            }.aspectRatio(1, contentMode: .fit)
                .onAppear {
                    self.isAnimating = true
                }
        }
        
    }
    
    struct ErrorView: View {
        let error: Error
        var body: some View {
            ZStack {
                Rectangle().fill(Color.gray)
//                Text(error.localizedDescription).font(Font.system(size: 8))
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
            .frame(width:BOOK_WIDTH, height:BOOK_HEIGHT)
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
    @State var downloaded = true
    static var previews: some View {
        BookCover(title: "1", fetchURL: URL(string:"https://picsum.photos/120/140")!)
//        DownloadView(downloaded: true)
    }
}
#endif
