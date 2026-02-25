import pyttsx3
import time

engine = pyttsx3.init()
engine.setProperty("rate", 165)

def speak(text):
    print("AI:", text)
    engine.say(text)
    engine.runAndWait()
    time.sleep(1)

def start_assistant():
    speak("Hello. I am your accident assistance AI.")
    speak("Please make sure you are safe and the vehicle is stopped.")
    speak("I will guide you to take photos for damage estimation.")

    photo_steps = [
        "Please take a clear photo of the FRONT side of the vehicle.",
        "Now take a photo of the LEFT side of the vehicle.",
        "Now take a photo of the RIGHT side of the vehicle.",
        "Please take a photo of the REAR side of the vehicle.",
        "Take a CLOSE-UP photo of the damaged area.",
        "Now take a photo of the vehicle NUMBER PLATE.",
        "Finally, take a photo showing the SURROUNDING area of the accident."
    ]

    for step in photo_steps:
        speak(step)
        input("Press ENTER after taking the photo...")

    speak("All photos have been captured successfully.")
    speak("You may now upload these images for quick estimate.")
    speak("Thank you. Drive safe.")

if __name__ == "__main__":
    start_assistant()
     