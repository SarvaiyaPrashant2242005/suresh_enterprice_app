const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const cookieParser = require("cookie-parser");
const dotenv = require("dotenv");
const { sequelize } = require("./models");
const compression = require("compression");
const helmet = require("helmet");
const morgan = require("morgan");

// Routes
const categoryRoutes = require("./routes/categoryRoutes");
const productRoutes = require("./routes/productRoutes");
const customerRoutes = require("./routes/customerRoutes");
const gstMasterRoutes = require("./routes/gstMasterRoutes");
const companyProfileRoutes = require("./routes/companyProfileRoutes");
const invoiceRoutes = require("./routes/invoiceRoutes");
const userRoutes = require("./routes/userRoutes");

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// ✅ Proper CORS setup
const corsOptions = {
  origin: [
    "http://localhost:50891",   // Flutter web dev port (auto-assigned)
    "http://localhost:5500",    // alternate dev port
    "http://192.168.1.5:50891", // LAN access for Chrome web
  ],
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"],
  credentials: true,
};

// ✅ Middleware setup
app.use(compression());
app.use(helmet({
  crossOriginResourcePolicy: { policy: "cross-origin" },
}));
app.use(morgan("combined"));
app.use(cors(corsOptions));
app.use(bodyParser.json());
app.use(cookieParser());
app.use("/uploads", express.static("uploads"));

// ✅ API Routes
app.use("/", (req,res) => {
  res.json({
    status : "ok",
    messege : "server is running"
  })
})
app.use("/api/categories", categoryRoutes);
app.use("/api/products", productRoutes);
app.use("/api/customers", customerRoutes);
app.use("/api/gstMasters", gstMasterRoutes);
app.use("/api/companyProfiles", companyProfileRoutes);
app.use("/api/invoices", invoiceRoutes);
app.use("/api/users", userRoutes);

// ✅ Global Error Handler
app.use((err, req, res, next) => {
  console.error("Error:", err.stack);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || "Internal Server Error",
  });
});

// ✅ Start server and connect to DB
(async () => {
  try {
    await sequelize.authenticate();
    console.log("✅ Database connected successfully");

    app.listen(PORT, "0.0.0.0", () => {
      console.log(`🚀 Server running at:`);
      console.log(`   → Local:  http://localhost:${PORT}`);
      console.log(`   → Network: http://192.168.1.5:${PORT}`);
    });
  } catch (error) {
    console.error("❌ Database connection failed:", error);
    process.exit(1);
  }
})();
