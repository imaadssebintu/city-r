package main

import (
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
		Engine:   "4.4L V8 Twin-Turbo", Transmission: "8-Speed Automatic", Drive: "AWD (xDrive)",
		Description: "Pristine BMW M5 Competition finished in Alpine White. Features include full Merino leather interior, Bowers & Wilkins Diamond surround sound, carbon ceramic brakes, and M Driver's Package. This car has been meticulously maintained by the main dealer.",
		DealerName:  "Premium Motors Bucharest", DealerPhone: "+40 722 123 456", DealerCity: "Bucharest",
		Gallery: []string{
			"https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800&q=80",
			"https://images.unsplash.com/photo-1558980394-4c7c9299fe96?w=800&q=80",
			"https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=800&q=80",
		},
	},
	{
		ID: 2, Make: "Mercedes-Benz", Model: "AMG GT 63", Year: 2023,
		Price: 142000, Mileage: 3100, BodyType: "Coupe", Fuel: "Petrol",
		Color: "Obsidian Black", Featured: true, Badge: "New",
		ImageURL: "https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=600&q=80",
		Engine:   "4.0L V8 BiTurbo", Transmission: "9-Speed Automatic", Drive: "AWD (4MATIC+)",
		Description: "Stunning AMG GT 63 4-Door Coupe. Fully loaded with exclusive Nappa leather, AMG aerodynamics package, 21-inch forged wheels, and rear axle steering.",
		DealerName:  "Elite Auto", DealerPhone: "+40 744 987 654", DealerCity: "Cluj-Napoca",
		Gallery: []string{"https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800&q=80"},
	},
	{
		ID: 3, Make: "Audi", Model: "RS6 Avant", Year: 2022,
		Price: 76000, Mileage: 22000, BodyType: "Estate", Fuel: "Petrol",
		Color: "Nardo Gray", Featured: true, Badge: "Low Mileage",
		ImageURL: "https://images.unsplash.com/photo-1603584173870-7f23fdae1b7a?w=600&q=80",
		Engine:   "4.0L V8 TFSI", Transmission: "8-Speed Tiptronic", Drive: "AWD (quattro)",
		Description: "The ultimate family estate. Nardo Gray RS6 with RS dynamic package, panoramic glass sunroof, and Bang & Olufsen Advanced Sound System.",
		DealerName:  "City-R Direct", DealerPhone: "+40 799 111 222", DealerCity: "Bucharest",
		Gallery: []string{"https://images.unsplash.com/photo-1603584173870-7f23fdae1b7a?w=800&q=80"},
	},
	{
		ID: 4, Make: "Porsche", Model: "Cayenne Turbo", Year: 2023,
		Price: 128000, Mileage: 5400, BodyType: "SUV", Fuel: "Petrol",
		Color: "Carrara White", Featured: true, Badge: "New",
		ImageURL: "https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=600&q=80",
		Engine:   "4.0L V8 Twin-Turbo", Transmission: "8-Speed Tiptronic S", Drive: "AWD",
		Description: "Like-new Cayenne Turbo. Air suspension, Porsche Dynamic Chassis Control (PDCC), Sport Chrono Package, and adaptive sports seats.",
		DealerName:  "Premium Motors Bucharest", DealerPhone: "+40 722 123 456", DealerCity: "Bucharest",
		Gallery: []string{"https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&q=80"},
	},
	{
		ID: 5, Make: "Tesla", Model: "Model S Plaid", Year: 2024,
		Price: 98000, Mileage: 1200, BodyType: "Sedan", Fuel: "Electric",
		Color: "Midnight Silver", Featured: true, Badge: "New",
		ImageURL: "https://images.unsplash.com/photo-1536700503339-1e4b06520771?w=600&q=80",
		Engine:   "Tri-Motor", Transmission: "1-Speed Direct Drive", Drive: "AWD",
		Description: "Incredible acceleration. Yoke steering, 21-inch Arachnid wheels, Full Self-Driving Capability, and black/white premium interior.",
		DealerName:  "EV Hub", DealerPhone: "+40 733 555 777", DealerCity: "Timisoara",
		Gallery: []string{"https://images.unsplash.com/photo-1536700503339-1e4b06520771?w=800&q=80"},
	},
	{
		ID: 6, Make: "Range Rover", Model: "Sport SVR", Year: 2022,
		Price: 95000, Mileage: 18700, BodyType: "SUV", Fuel: "Petrol",
		Color: "Santorini Black", Featured: true, Badge: "Hot Deal",
		ImageURL: "https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=600&q=80",
		Engine:   "5.0L V8 Supercharged", Transmission: "8-Speed Automatic", Drive: "4WD",
		Description: "Aggressive SVR styling. Carbon fibre exterior pack, SVR performance seats, Meridian Signature Sound System, and sliding panoramic roof.",
		DealerName:  "Elite Auto", DealerPhone: "+40 744 987 654", DealerCity: "Cluj-Napoca",
		Gallery: []string{"https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=800&q=80"},
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

	return c.Render("home", fiber.Map{
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
		"Title":       car.Year,
		"Car":         car,
		"RelatedCars": relatedCars,
	}, "layout")
}
