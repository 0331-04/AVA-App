import pyttsx3
import time
import cv2
import os

engine = pyttsx3.init()
engine.setProperty("rate", 165)

def speak(text):
    print("AI:", text)
    engine.say(text)
    engine.runAndWait()
    time.sleep(1)

def is_blurry(image_path, threshold=100):
    image = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    if image is None:
        return True
    variance = cv2.Laplacian(image, cv2.Cv_64F).var()
    return variance < threshold

def take_photo_step(step_name, phtot_name):
    while True:
        speak (step_name)
        image_path= input ("Enter image file path (after taking photo): ")

        if not os.path.exists(image_path):
            speak("I cannot find the imaage. Please try again.")
            continue

        confirm = input (" Is damage clearly visible? (yes/no): ").lower()
        if confirm == "yes":
            speak("Photo accepted.")
            break
        else:
            speak("Please retake the photo clearly. ")

def start_assistant():
    speak("Hello. I am your accident assistance AI.")
    speak("Please make sure you are safe and the vehicle is stopped.")
    speak("I will guide you to take photos for damage estimation.")

    photo_steps = [
        ("Take a FRONT side photo of the vehicle.", "front.jpg"),
        ("Take a LEFT side photo of the vehicle.", "left.jpg"),
        ("Take a RIGHT side photo of the vehicle.", "right.jpg"),
        ("Take a REAR side photo of the vehicle.", "rear.jpg"),
        ("Take a CLOSE UP photo of the damaged area.", "damage.jpg")
    ]

    for step,filename in photo_steps:
        take_photo_step(step, filename)

    speak("All photos have been captured successfully.")
    speak("You may now upload these images for quick estimate.")
    speak("Thank you. Drive safe.")

if __name__ == "__main__":
    start_assistant()
     