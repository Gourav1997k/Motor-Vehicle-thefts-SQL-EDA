## 🔍 Exploratory Data Analysis (EDA)

My analysis was done entirely in SQL to keep the data processing efficient. I didn't just want to count rows; I wanted to understand the relationship between the vehicle characteristics and the location data to see if real patterns emerged.

Here is how I broke down the work:

### 1. Data Quality & Cleaning
Before running any trends, I had to make sure the data was reliable. I checked for `NULL` values across the key columns and found about 26 records where the `vehicle_type` was missing. I decided to keep them in the dataset because the `date_stolen` fields were still valid and vital for the timeline analysis.

I also had to perform some light schema updates, specifically converting the `location_id` to an integer to ensure the joins between the `stolen_vehicles` and `locations` tables worked correctly.

### 2. The "Typical" Stolen Vehicle Profile
I ran several aggregation queries to build a profile of the most targeted cars. The data suggests that newer cars aren't necessarily the main target.

* **Vehicle Age:** By calculating the difference between the theft date and the model year, I found the average age of a stolen vehicle is roughly **16 years**.
* **Color & Type:** Silver is the most stolen color by a significant margin, followed by White and Black. In terms of body type, Station wagons and Saloons top the list, whereas specialized vehicles like tractors or trail bikes are rarely taken.
* **Specific Models:** I filtered for make/model combinations with at least 5 thefts to identify hotspots. The **Toyota Hilux** and **Ford Courier** appeared as the most frequently stolen specific models.

### 3. Temporal Trends
I looked at the theft timelines to see if there was a seasonal pattern.
* **Daily:** I grouped the data by day of the week to see if weekends or weekdays were riskier.
* **Monthly:** There is a clear upward trend in the dataset. Thefts ramped up consistently from October, peaking in March.

### 4. Correlation Analysis: Population vs. Theft
I wanted to see if the theft numbers were just a result of population density or if certain regions were disproportionately dangerous.

To test this, I wrote a query to calculate the **Pearson Correlation Coefficient** manually between population size and theft count.
* **The Result:** 0.9821
* **The Insight:** This extremely strong positive correlation suggests that theft in New Zealand is almost entirely a function of population size. Auckland has the most thefts simply because it has the most people, rather than being an outlier due to other factors.
