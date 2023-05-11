
import pandas as pd
import altair as alt

# Load the data
data = pd.read_csv(r"C:\Users\Dell\Desktop\updated.csv")

# Create a bar chart of drug types by admission type
chart = alt.Chart(data).mark_bar().encode(
    x=alt.X('DRG_TYPE:N', axis=alt.Axis(title='Drug Type')),
    y=alt.Y('count()', axis=alt.Axis(title='Number of Patients')),
    color=alt.Color('ADMISSION_TYPE:N', legend=alt.Legend(title='Admission Type'))
).properties(
    title='Drug Types by Admission Type'
)

# Show the chart
chart
import pandas as pd
import altair as alt

# Load the data
data = pd.read_csv(r"C:\Users\Dell\Desktop\updated.csv")

# Create a stacked bar chart of drug types and admission types
chart = alt.Chart(data).mark_bar().encode(
    x=alt.X('ADMISSION_TYPE:N', axis=alt.Axis(title='Admission Type')),
    y=alt.Y('count()', axis=alt.Axis(title='Number of Patients')),
    color=alt.Color('DRG_TYPE:N', legend=alt.Legend(title='Drug Type'))
).properties(
    title='Drug Types and Admission Types'
)

# Show the chart
chart

import pandas as pd
import altair as alt

# Load the data
data = pd.read_csv(r"C:\Users\Dell\Desktop\updated.csv")

# Create a grouped bar chart of drug types by admission type and gender
chart = alt.Chart(data).mark_bar().encode(
    x=alt.X('DRUG_TYPE:N', axis=alt.Axis(title='Drug Type')),
    y=alt.Y('count()', axis=alt.Axis(title='Number of Patients')),
    color=alt.Color('ADMISSION_TYPE:N', legend=alt.Legend(title='Admission Type')),
    column=alt.Column('GENDER:N', header=alt.Header(title='Gender'))
).properties(
    title='Drug Types by Admission Type and Gender'
)

# Show the chart
chart

import pandas as pd
import matplotlib.pyplot as plt

# Load the dataset
data = pd.read_csv(r"C:\Users\Dell\Desktop\updated.csv")

# Select a patient by SUBJECT_ID
patient_id = 12345
patient_data = data[data["SUBJECT_ID"] == patient_id]

# Create a bar chart of the drug type and admission type for the patient
fig, ax = plt.subplots()
ax.bar(patient_data["DRG_TYPE"], patient_data["ADMISSION_TYPE"])
ax.set_xlabel("Drug Type")
ax.set_ylabel("Admission Type")
ax.set_title(f"Patient Record for SUBJECT_ID {patient_id}")
plt.show()


