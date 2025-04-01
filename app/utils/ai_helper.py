import openai  # אם עובדים עם OpenAI API

def get_ai_response(prompt):
    """שולח פרומפט למנוע AI ומחזיר את החפצים המסוכנים"""
    response = openai.ChatCompletion.create(
        model="gpt-4",
        messages=[{"role": "system", "content": "אתה עוזר באיתור חפצים מסוכנים לתינוקות."},
                  {"role": "user", "content": prompt}]
    )
    return response["choices"][0]["message"]["content"].split("\n")  # מחזיר רשימה של חפצים
