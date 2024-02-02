import UIKit

// Assuming 'Movie' conforms to Decodable for API response parsing
struct Movie: Decodable {
    let title: String
    let releaseDate: String
    let id: Int
    let posterPath: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case releaseDate = "release_date"
        case id
        case posterPath = "poster_path"
    }
}

struct ApiResponse: Decodable {
    let results: [Movie]
}

class MovieTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
}

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies: [Movie] = []
    var filteredMovies: [Movie] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSearchBar()
        fetchMovies()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120 // Or a ballpark estimate of your cell height
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func setupSearchBar() {
        searchBar.delegate = self
    }

    @IBAction func addNewMovie(_ sender: UIBarButtonItem) {
        // Present an alert with text fields to input the new movie details
        let alertController = UIAlertController(title: "Add New Movie", message: nil, preferredStyle: .alert)
        
        // Add text fields to the alert for each movie detail
        alertController.addTextField { textField in
            textField.placeholder = "Title"
        }
        alertController.addTextField { textField in
            textField.placeholder = "Year"
        }
        alertController.addTextField { textField in
            textField.placeholder = "IMDb ID"
        }
        alertController.addTextField { textField in
            textField.placeholder = "Type"
        }
        alertController.addTextField { textField in
            textField.placeholder = "Poster URL"
        }
        
        // Add a "Save" action to the alert
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let title = alertController.textFields?[0].text,
                  let year = alertController.textFields?[1].text,
                  let imdbID = alertController.textFields?[2].text,
                  let _ = alertController.textFields?[3].text,
                  let posterPath = alertController.textFields?[4].text else { return }
            
            // Create a new Movie object with the input details
            let newMovie = Movie(title: title, releaseDate: year, id: Int(imdbID) ?? 0, posterPath: posterPath)
            
            // Add the new movie to the movies array and reload the table view
            self?.movies.append(newMovie)
            self?.filteredMovies.append(newMovie)
            self?.tableView.reloadData()
        }
        
        // Add a "Cancel" action to the alert
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        // Add actions to the alert
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        // Present the alert
        present(alertController, animated: true)
    }



    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMovieDetail", let indexPath = tableView.indexPathForSelectedRow {
            let movie = filteredMovies[indexPath.row]
            if let destinationVC = segue.destination as? MovieDetailViewController {
                destinationVC.movie = movie
            }
        }
    }
    
    func fetchMovies() {
        let apiKey = "bbf21160b67ebc66a4b6e46cb46a556b"
        let urlString = "https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let apiResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.movies = apiResponse.results
                    self?.filteredMovies = apiResponse.results
                    self?.tableView.reloadData()
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }

}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as? MovieTableViewCell else {
            fatalError("Unable to dequeue MovieTableViewCell")
        }
        let movie = filteredMovies[indexPath.row]
        cell.titleLabel.text = movie.title
        cell.yearLabel.text = String(movie.releaseDate.prefix(4))
        
        print("Title: \(movie.title)")
        print("Year: \(String(movie.releaseDate.prefix(4)))")
        print("Poster Path: \(movie.posterPath)")
        
        let posterBaseUrl = "https://image.tmdb.org/t/p/w500"
        if let posterURL = URL(string: posterBaseUrl + movie.posterPath) {
            URLSession.shared.dataTask(with: posterURL) { data, response, error in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.posterImageView.image = UIImage(data: data)
                        cell.posterImageView.setNeedsLayout()
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.posterImageView.image = UIImage(systemName: "film") // Placeholder image
                    }
                }
            }.resume()
        } else {
            cell.posterImageView.image = UIImage(systemName: "film") // Placeholder image if URL is incorrect
        }
        
        return cell
    }


}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowMovieDetail", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Determine if the movie is in the filtered array and find its index in the main array
            let movieToDelete = filteredMovies[indexPath.row]
            if let indexInMainArray = movies.firstIndex(where: { $0.id == movieToDelete.id }) {
                // Remove the movie from both arrays
                movies.remove(at: indexInMainArray)
                filteredMovies.remove(at: indexPath.row)
                
                // Now, update the table view
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }

}

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = searchText.isEmpty ? movies : movies.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        tableView.reloadData()
    }
}

// Assuming you have a MovieDetailViewController like this
class MovieDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var imdbIDLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!

    var movie: Movie?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    private func updateUI() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
        yearLabel.text = String(movie.releaseDate.prefix(4))
        imdbIDLabel.text = String(movie.id)
        typeLabel.text = "Movie"
        
        let posterBaseUrl = "https://image.tmdb.org/t/p/w500"
        if let posterURL = URL(string: posterBaseUrl + movie.posterPath) {
            URLSession.shared.dataTask(with: posterURL) { data, response, error in
                if let data = data {
                    DispatchQueue.main.async {
                        self.posterImageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
    }
}
