# KSP Lam Gabe Jaya - Database Exports

## Database Structure for KSP Lam Gabe Jaya Cooperative Financial Management System

### 🗄️ **Database Files**

#### **Main Database Exports**
- **mono_v2_db_export.sql** - Main application database (users, members, loans, savings, transactions)
- **people_db_export.sql** - HR and personnel database (occupations, employee data)
- **alamat_db_export.sql** - Indonesian geographic database (provinces, cities, districts)
- **mono_v2_complete_export.sql** - Complete database export (all databases combined)

### 📊 **Database Architecture**

#### **mono_v2 Database**
- **users** - User authentication and roles
- **members** - Member data and accounts
- **loans** - Loan management
- **savings** - Savings accounts
- **transactions** - Financial transactions
- **audit_trail** - Activity logging

#### **people_db Database**
- **occupations** - Standardized occupation codes
- **personnel** - Extended member employment data

#### **alamat_db Database**
- **provinces** - Indonesian provinces
- **cities** - Indonesian cities/regencies
- **districts** - Indonesian districts

### 🚀 **Setup Instructions**

1. Import database files in order:
   ```bash
   mysql -u root -p < mono_v2_db_export.sql
   mysql -u root -p < people_db_export.sql
   mysql -u root -p < alamat_db_export.sql
   ```

2. Or use complete export:
   ```bash
   mysql -u root -p < mono_v2_complete_export.sql
   ```

### 📅 **Last Updated**
- **Date**: 2026-03-25
- **Version**: Production Ready
- **Status**: Complete with test data

### 🔗 **Related Repository**
- **Main Application**: https://github.com/82080038/mono-v2/tree/kantor

---

**Note**: These database exports are for the KSP Lam Gabe Jaya cooperative financial management system.
