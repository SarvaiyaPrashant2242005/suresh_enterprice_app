const sequelize = require("../config/db");
const { DataTypes } = require("sequelize");
const CompanyProfiles = require("./companyProfile");

const Category = sequelize.define(
  "Category",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    company_id: {
      type: DataTypes.STRING(4), // Changed from INTEGER to STRING(4)
      allowNull: false,
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
    },
  },
  {
    tableName: "categories",
    timestamps: true,
  }
);

// Define the association
CompanyProfiles.hasMany(Category, {
  foreignKey: "company_id",
  onDelete: "CASCADE",
  onUpdate: "CASCADE",
});

Category.belongsTo(CompanyProfiles, {
  foreignKey: "company_id",
});

module.exports = Category;