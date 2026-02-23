package main

import (
	"fmt"
	"log"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/template/html/v2"
)

// Car represents a vehicle listing
type Car struct {
	ID       int
	Make     string
	Model    string
	Year     int
	Price    int
	Mileage  int
	BodyType string
	Fuel     string
	Color    string
	ImageURL string
	Featured bool
	Badge    string // e.g. "New", "Hot Deal", "Low Mileage"
	// Details page extras
	Engine       string
	Transmission string
	Drive        string
	Description  string
	Gallery      []string
	DealerName   string
	DealerPhone  string
	DealerCity   string
}

// In-memory car listings
var cars = []Car{
	{
		ID: 1, Make: "BMW", Model: "M5 Competition", Year: 2023,
		Price: 89500, Mileage: 8200, BodyType: "Sedan", Fuel: "Petrol",
		Color: "Alpine White", Featured: true, Badge: "Hot Deal",
		ImageURL: "https://images.unsplash.com/photo-1555215695-3004980ad54e?w=600&q=80",
		Engine:   "4.4L V8 Twin-Turbo", Transmission: "Automatic", Drive: "AWD (xDrive)",
		Description: "Pristine BMW M5 Competition.",
		DealerName:  "Premium Motors", DealerPhone: "+40 722 123 456", DealerCity: "Bucharest",
	},
	{
		ID: 2, Make: "Mercedes-Benz", Model: "AMG GT 63", Year: 2023,
		Price: 142000, Mileage: 3100, BodyType: "Coupe", Fuel: "Petrol",
		Color: "Obsidian Black", Featured: true, Badge: "New",
		ImageURL: "https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=600&q=80",
		Engine:   "4.0L V8 BiTurbo", Transmission: "Automatic", Drive: "AWD (4MATIC+)",
		Description: "Stunning AMG GT 63.",
		DealerName:  "Elite Auto", DealerPhone: "+40 744 987 654", DealerCity: "Cluj-Napoca",
	},
	{
		ID: 3, Make: "Audi", Model: "RS6 Avant", Year: 2022,
		Price: 76000, Mileage: 22000, BodyType: "Estate", Fuel: "Petrol",
		Color: "Nardo Gray", Featured: true, Badge: "Low Mileage",
		ImageURL: "https://images.unsplash.com/photo-1603584173870-7f23fdae1b7a?w=600&q=80",
		Engine:   "4.0L V8 TFSI", Transmission: "CVT", Drive: "AWD (quattro)",
		Description: "The ultimate family estate.",
		DealerName:  "City-R Direct", DealerPhone: "+40 799 111 222", DealerCity: "Bucharest",
	},
	{
		ID: 4, Make: "Porsche", Model: "Cayenne Turbo", Year: 2023,
		Price: 128000, Mileage: 5400, BodyType: "SUV", Fuel: "Petrol",
		Color: "Carrara White", Featured: true, Badge: "New",
		ImageURL: "https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=600&q=80",
		Engine:   "4.0L V8 Twin-Turbo", Transmission: "CVT", Drive: "AWD",
		Description: "Like-new Cayenne Turbo.",
		DealerName:  "Premium Motors", DealerPhone: "+40 722 123 456", DealerCity: "Bucharest",
	},
	{
		ID: 5, Make: "Tesla", Model: "Model S Plaid", Year: 2024,
		Price: 98000, Mileage: 1200, BodyType: "Sedan", Fuel: "Electric",
		Color: "Midnight Silver", Featured: true, Badge: "New",
		ImageURL: "https://images.unsplash.com/photo-1536700503339-1e4b06520771?w=600&q=80",
		Engine:   "Tri-Motor", Transmission: "Automatic", Drive: "AWD",
		Description: "Incredible acceleration.",
		DealerName:  "EV Hub", DealerPhone: "+40 733 555 777", DealerCity: "Timisoara",
	},
	{
		ID: 6, Make: "Range Rover", Model: "Sport SVR", Year: 2022,
		Price: 95000, Mileage: 18700, BodyType: "SUV", Fuel: "Petrol",
		Color: "Santorini Black", Featured: true, Badge: "Hot Deal",
		ImageURL: "https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=600&q=80",
		Engine:   "5.0L V8 Supercharged", Transmission: "Automatic", Drive: "4WD",
		Description: "Aggressive SVR styling.",
		DealerName:  "Elite Auto", DealerPhone: "+40 744 987 654", DealerCity: "Cluj-Napoca",
	},
	{
		ID: 7, Make: "Toyota", Model: "Land Cruiser 300", Year: 2023,
		Price: 115000, Mileage: 1500, BodyType: "SUV", Fuel: "Diesel",
		Color: "Pearl White", Featured: true, Badge: "New",
		ImageURL: "https://images.unsplash.com/photo-1594502184342-2e12f877aa73?w=600&q=80",
		Engine:   "3.3L V6 Twin-Turbo", Transmission: "Automatic", Drive: "4WD",
		DealerName: "Global Motors", DealerCity: "Bucharest",
	},
	{
		ID: 8, Make: "Volkswagen", Model: "Golf R", Year: 2024,
		Price: 52000, Mileage: 500, BodyType: "Hatchback", Fuel: "Petrol",
		Color: "Lapiz Blue", Featured: true, Badge: "New",
		ImageURL: "https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=600&q=80",
		Engine:   "2.0L Turbo", Transmission: "Automatic", Drive: "AWD",
		DealerName: "City-R Direct", DealerCity: "Bucharest",
	},
	{
		ID: 9, Make: "Ford", Model: "Mustang Mach-E", Year: 2023,
		Price: 65000, Mileage: 4200, BodyType: "SUV", Fuel: "Electric",
		Color: "Rapid Red", Featured: true, Badge: "Hot Deal",
		ImageURL: "https://images.unsplash.com/photo-1619767886558-efdc259cde1a?w=600&q=80",
		Engine:   "Dual-Motor", Transmission: "Automatic", Drive: "AWD",
		DealerName: "Elite Auto", DealerCity: "Cluj-Napoca",
	},
	{
		ID: 10, Make: "Hyundai", Model: "IONIQ 5", Year: 2024,
		Price: 58000, Mileage: 100, BodyType: "SUV", Fuel: "Electric",
		Color: "Gravity Gold", Featured: true, Badge: "New",
		ImageURL: "https://images.unsplash.com/photo-1556189250-72ba954cfc2b?w=600&q=80",
		Engine:   "77.4 kWh Battery", Transmission: "Automatic", Drive: "RWD",
		DealerName: "EV Hub", DealerCity: "Timisoara",
	},
	{
		ID: 11, Make: "Dacia", Model: "Duster", Year: 2024,
		Price: 24500, Mileage: 50, BodyType: "SUV", Fuel: "Hybrid",
		Color: "Sandero Green", Featured: true, Badge: "New",
		ImageURL: "https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=600&q=80",
		Engine:   "1.6L Hybrid", Transmission: "Automatic", Drive: "FWD",
		DealerName: "City-R Direct", DealerCity: "Bucharest",
	},
	{
		ID: 12, Make: "Toyota", Model: "RAV4 Hybrid", Year: 2023,
		Price: 42000, Mileage: 12000, BodyType: "SUV", Fuel: "Hybrid",
		Color: "Silver Metallic", Featured: true, Badge: "Low Mileage",
		ImageURL: "https://images.unsplash.com/photo-1583121274602-3e2820c69888?w=600&q=80",
		Engine:   "2.5L Hybrid", Transmission: "CVT", Drive: "AWD",
		DealerName: "Global Motors", DealerCity: "Bucharest",
	},
	{
		ID: 13, Make: "BMW", Model: "X5 xDrive45e", Year: 2022,
		Price: 72000, Mileage: 34000, BodyType: "SUV", Fuel: "Hybrid",
		Color: "Carbon Black", Featured: true, Badge: "Hot Deal",
		ImageURL: "https://images.unsplash.com/photo-1556189250-72ba954cfc2b?w=600&q=80",
		Engine:   "3.0L Plug-in Hybrid", Transmission: "Automatic", Drive: "AWD",
		DealerName: "Premium Motors", DealerCity: "Bucharest",
	},
	{
		ID: 14, Make: "Skoda", Model: "Octavia RS", Year: 2023,
		Price: 38500, Mileage: 15600, BodyType: "Sedan", Fuel: "Diesel",
		Color: "Mamba Green", Featured: true, Badge: "Low Mileage",
		ImageURL: "https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?w=600&q=80",
		Engine:   "2.0L TDI", Transmission: "Automatic", Drive: "FWD",
		DealerName: "City-R Direct", DealerCity: "Bucharest",
	},
	{
		ID: 15, Make: "Mercedes-Benz", Model: "E-Class", Year: 2024,
		Price: 68000, Mileage: 200, BodyType: "Sedan", Fuel: "Diesel",
		Color: "Selenite Grey", Featured: true, Badge: "New",
		ImageURL: "https://images.unsplash.com/photo-1617531653332-bd46c24f2068?w=600&q=80",
		Engine:   "2.0L Diesel", Transmission: "Automatic", Drive: "AWD",
		DealerName: "Elite Auto", DealerCity: "Cluj-Napoca",
	},
	{
		ID: 16, Make: "Audi", Model: "Q7", Year: 2021,
		Price: 59000, Mileage: 48000, BodyType: "SUV", Fuel: "Diesel",
		Color: "Glacier White", Featured: true, Badge: "Hot Deal",
		ImageURL: "https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=600&q=80",
		Engine:   "3.0L V6 TDI", Transmission: "Automatic", Drive: "AWD",
		DealerName: "City-R Direct", DealerCity: "Bucharest",
	},
	{
		ID: 17, Make: "Volkswagen", Model: "ID.4", Year: 2023,
		Price: 45000, Mileage: 8900, BodyType: "SUV", Fuel: "Electric",
		Color: "Blue Dusk", Featured: true, Badge: "Low Mileage",
		ImageURL: "https://images.unsplash.com/photo-1621135802920-133df287f89c?w=600&q=80",
		Engine:   "Electric", Transmission: "Automatic", Drive: "RWD",
		DealerName: "EV Hub", DealerCity: "Timisoara",
	},
	{
		ID: 18, Make: "Nissan", Model: "Qashqai", Year: 2023,
		Price: 32000, Mileage: 8000, BodyType: "SUV", Fuel: "Hybrid",
		Color: "Magnetic Blue", Featured: true, Badge: "Low Mileage",
		ImageURL: "https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=600&q=80",
		Engine:   "1.3L Mild Hybrid", Transmission: "CVT", Drive: "FWD",
		DealerName: "City-R Direct", DealerCity: "Bucharest",
	},
	{
		ID: 19, Make: "Volvo", Model: "XC60 Recharge", Year: 2023,
		Price: 56000, Mileage: 11000, BodyType: "SUV", Fuel: "Hybrid",
		Color: "Denim Blue", Featured: true, Badge: "Low Mileage",
		ImageURL: "https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=600&q=80",
		Engine:   "2.0L Plug-in Hybrid", Transmission: "Automatic", Drive: "AWD",
		DealerName: "Premium Motors", DealerCity: "Bucharest",
	},
	{
		ID: 20, Make: "Kia", Model: "EV6", Year: 2023,
		Price: 54000, Mileage: 14500, BodyType: "SUV", Fuel: "Electric",
		Color: "Yacht Blue", Featured: true, Badge: "Hot Deal",
		ImageURL: "https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?w=600&q=80",
		Engine:   "77.4 kWh", Transmission: "Automatic", Drive: "AWD",
		DealerName: "EV Hub", DealerCity: "Timisoara",
	},
	{
		ID: 21, Make: "Mazda", Model: "CX-5", Year: 2024,
		Price: 38000, Mileage: 100, BodyType: "SUV", Fuel: "Petrol",
		Color: "Soul Red Crystal", Featured: true, Badge: "New",
		ImageURL: "https://images.unsplash.com/photo-1603584173870-7f23fdae1b7a?w=600&q=80",
		Engine:   "2.5L Skyactiv-G", Transmission: "Automatic", Drive: "AWD",
		DealerName: "Global Motors", DealerCity: "Bucharest",
	},
}

// Stats for the homepage
type Stats struct {
	TotalListings   int
	HappyCustomers  int
	YearsInBusiness int
	CarsDelivered   int
}

func main() {
	// Initialize HTML template engine
	engine := html.New("./views", ".html")

	app := fiber.New(fiber.Config{
		Views: engine,
	})

	// Serve static files
	app.Static("/static", "./static")

	// ─── Routes ────────────────────────────────────────────────
	app.Get("/", handleHome)
	app.Get("/cars/:id", handleDetails)

	log.Println("🚗  City-R Car Marketplace running on http://localhost:3000")
	log.Fatal(app.Listen(":3000"))
}

func handleHome(c *fiber.Ctx) error {
	featured := []Car{}
	for _, car := range cars {
		if car.Featured {
			featured = append(featured, car)
		}
	}

	stats := Stats{
		TotalListings:   len(cars),
		HappyCustomers:  1240,
		YearsInBusiness: 8,
		CarsDelivered:   3800,
	}

	return c.Render("index", fiber.Map{
		"Title":        "City-R | Premium Car Marketplace",
		"FeaturedCars": featured,
		"Stats":        stats,
	}, "layout")
}

func handleDetails(c *fiber.Ctx) error {
	id, err := c.ParamsInt("id")
	if err != nil {
		return c.Status(400).SendString("Invalid ID")
	}

	var car *Car
	for i := range cars {
		if cars[i].ID == id {
			car = &cars[i]
			break
		}
	}

	if car == nil {
		return c.Status(404).SendString("Car not found")
	}

	// Fetch some related cars for "Other cars from this dealer"
	relatedCars := []Car{}
	for _, c := range cars {
		if c.ID != car.ID && len(relatedCars) < 3 {
			relatedCars = append(relatedCars, c)
		}
	}

	return c.Render("details", fiber.Map{
		"Title":       fmt.Sprintf("%d %s %s", car.Year, car.Make, car.Model),
		"Car":         car,
		"RelatedCars": relatedCars,
	}, "layout")
}
