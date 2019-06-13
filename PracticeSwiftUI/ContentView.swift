import SwiftUI
import Combine

struct ContentView : View {
    
    @ObjectBinding var model: Model = Model()
    
    var body: some View {
        VStack {
            
            HStack {
                TextField($model.text, placeholder: Text("Search"))
                Button(action: {
                    self.model.loadUser()
                }) {
                    Text("Done")
                }
            }
            
            model.user.map { user in
                VStack {
                    Text(user.login)
                    Text("\(user.id)")
                    
                    user.avatarURL.map({self.showImage(avatarURL: $0)}).clipShape(Circle())
                }
            }
        }
    }
    
    func showImage(avatarURL: String?) -> Image? {
        guard let avatarURL = avatarURL, let url = URL(string: avatarURL), let data = try? Data(contentsOf: url), let image = UIImage(data: data) else {
            return nil
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
    
    var user: User? {
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
    let avatarURL: String?
    
    enum CodingKeys: String, CodingKey {
        case login
        case id
        case avatarURL = "avatar_url"
    }
}
