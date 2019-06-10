import SwiftUI
import Combine

struct ContentView : View {
    
    @ObjectBinding var model: Model = Model()
    
    var body: some View {
        VStack {
            
            HStack {
                TextField($model.text, placeholder: Text("Search"))
                    .font(.largeTitle)
                    .font(.system(size: 24))
                    .padding(.top, 16)
                    .padding(.leading, 16)
                Button(action: {
                    self.model.loadUser()
                }) {
                    Text("Done")
                        .bold()
                        .font(Font.system(size: 24))
                        .padding(.top, 16)
                        .padding(.trailing, 32)
                }
            }
            
            HStack {
                Text(model.user.login).bold().font(.system(.title))
                Text("\(model.user.id)").bold().font(.system(.title))
                showImage().clipShape(Circle())
            }
        }
    }
    
    func showImage() -> Image {
        guard let url = URL(string: model.user.avatarURL), let data = try? Data(contentsOf: url), let image = UIImage(data: data) else {
            return Image(systemName: "photo")
        }
        return Image(uiImage: image)
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

class Model: BindableObject {
    
    var didChange = PassthroughSubject<Model, Never>()
    
    var text: String = ""
    
    var user: User = User(login: "", id: 0, avatarURL: "") {
        didSet {
            didChange.send(self)
        }
    }
    
    func loadUser() {
        let baseURL = URLComponents(string: "https://api.github.com/users/\(text)")!
        URLSession.shared.dataTask(with: baseURL.url!) { (data, response, error) in
            guard let data = data, let user = try? JSONDecoder().decode(User.self, from: data) else { return }
            DispatchQueue.main.async {
                self.user = user
            }
            }.resume()
    }
}

struct User: Decodable, Hashable {
    let login: String
    let id: Int
    let avatarURL: String
    
    enum CodingKeys: String, CodingKey {
        case login
        case id
        case avatarURL = "avatar_url"
    }
}
