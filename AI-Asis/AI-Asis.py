import pyttsx3
import time
import cv2
import os
from datetime import datetime


def speak(text):
    print("AI:", text)
    time.sleep(1)

def is_blurry(image_path, threshold=100):
    image = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    if image is None:
        return True
    variance = cv2.Laplacian(image, cv2.Cv_64F).var()
    return variance < threshold

def is_too_dark(image_path, threshold=40):
    image = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    if image is None:
        return True
    return image.mean() < threshold
    

def ask_damage_type_console():
    valid_types = ["scratch", "dent", "broken light", "glass damage"]
    while True:
        damage = input("What is the damage type? (scratch/dent/broken light/glass damage): ").lower()
        if damage in valid_types:
            speak(f"You selected {damage}.")
            return damage
        else:
            speak("Invalid damage type. Please type one of: scratch, dent, broken light, glass damage.")


def take_photo_step(step_name, photo_name,save_dir):
    while True:
        speak (step_name)
        image_path= input ("Enter image file path (after taking photo): ")

        if not os.path.exists(image_path):
            speak("I cannot find the imaage. Please try again.")
            continue

        if is_blurry(image_path):
            speak("The photo is blurry. Please retake it clearly.")
            continue

        if is_too_dark(image_path):
            speak("The photo os too dark. Please use flash and retake.")
            continue 


        confirm = input (" Is damage clearly visible? (yes/no): ").lower()
        if confirm == "yes":
            
            os.makedirs(save_dir, exist_ok=True)
            save_path= os.path.join(save_dir, photo_name)
            os.remane(image_path, save_path)

            timestamp= datetime.now().strfttime("%Y-%m-%d %H:%M:%S")
            gps_loction= "N/A"
            with open(os.path.join(save_dir, "photo_log.text"), "a")as f:
                f.write(f"{photo_name}captured at {timestamp}, GPS: {gps_location}\n")
            
            speak("Photo accepted and saved.")

            break
        else:
            speak("Please retake the photo clearly. ")

def start_assistant():
    speak("Hello. I am your accident assistance AI.")
    speak("Please make sure you are safe and the vehicle is stopped.")
    speak("I will guide you to take photos for damage estimation.")

    damage_type = ask_damage_type_console()

    photo_steps = [
        ("Take a FRONT side photo of the vehicle.", "front.jpg"),
        ("Take a LEFT side photo of the vehicle.", "left.jpg"),
        ("Take a RIGHT side photo of the vehicle.", "right.jpg"),
        ("Take a REAR side photo of the vehicle.", "rear.jpg"),
        ("Take a CLOSE UP photo of the damaged area.", "damage.jpg")
    ]

    save_dir="accident_photos"

    for step,filename in photo_steps:
        take_photo_step(step, filename, save_dir)

    speak("All photos have been captured successfully.")
    speak("You may now upload these images for quick estimate.")
    speak("Thank you. Drive safe.")

if __name__ == "__main__":
    start_assistant()
     