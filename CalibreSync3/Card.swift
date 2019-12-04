import SwiftUI
import Combine

struct Card: View {
    let title: String
    let fetchURL: URL
    
    var body: some View {
        ZStack(alignment: .init(horizontal: .center, vertical: .center)) {
            ImageView(withURL: fetchURL)
                .aspectRatio(contentMode: .fit)
//            Text(title)
//                .font(.title)
//                .foregroundColor(.white)
//                .opacity(0.5)
        }
//        .overlay(
//            RoundedRectangle(cornerRadius: 16)
//                .strokeBorder(Color.white.opacity(0.3), lineWidth: 4)
//        )
//        .cornerRadius(16)
    }
    
    struct ImageView: View {
        @ObservedObject var imageLoader:ImageLoader2
        @State var image:UIImage = UIImage(imageLiteralResourceName: "cover")
        
        init(withURL url:URL) {
            print("init")
            
            self.imageLoader = ImageLoader2(urlString:url)
        }
        
        var body: some View {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:120, height:140)
                .padding(10)
                .onReceive(imageLoader.didChange) { data in
                    self.image = UIImage(data: data) ?? UIImage()
                }
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
//        DispatchQueue.serial(qos: .userInitiated).async {
        DispatchQueue(label: "helloworld").async {
            self.task = URLSession.shared.dataTask(with: self.fetchURL) { data, response, error in
                guard let data = data else { return }
                DispatchQueue.main.async {
                    print("downloaded")
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
struct Card_Previews: PreviewProvider {
    static var previews: some View {
        Card(title: "1", fetchURL: URL(string:"https://picsum.photos/120/140")!)
    }
}
#endif
