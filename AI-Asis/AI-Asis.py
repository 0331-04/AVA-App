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
    variance = cv2.Laplacian(image, cv2.CV_64F).var()
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

def capturePhoto (photo_name, save_dir):

    if save_dir is None:
        save_dir = "accident _photos"

    os.makedirs(save_dir, exist_ok=True)
    save_path = None
    cap =cv2.VideoCapture(0, cv2.CAP_DSHOW)
    speak("Camera opened. Press C to capture photo.")
    

    while True:
        ret, frame = cap.read()
        
        if not ret:
            speak ("Cannot access camera.")
            break

        cv2.imshow("camera- press C to Capture", frame)

        key = cv2.waitKey(1) & 0xFF 

        if key == ord('c'):
            save_path = os.path.join (save_dir, photo_name)
            cv2.imwrite(save_path, frame)
            speak("Photo captured.")
            break

        elif key== ord('q'):
            save_path=None
            break

    cap.release()
    cv2.destroyAllWindows()

    return save_path

                


def take_photo_step(step_name, photo_name,save_dir):
    while True:
        speak (step_name)
        image_path= capturePhoto(photo_name, save_dir)

        if image_path is None:
            continue


        if is_blurry(image_path):
            speak("The photo is blurry. Please retake it clearly.")
            os.remove(image_path)
            continue

        if is_too_dark(image_path):
            speak("The photo os too dark. Please use flash and retake.")
            os.remove(image_path)
            continue  


        confirm = input (" Is damage clearly visible? (yes/no): ").lower()
        if confirm == "yes":
            

            timestamp= datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            gps_location= "N/A"
            with open(os.path.join(save_dir, "photo_log.text"), "a")as f:
                f.write(f"{photo_name}captured at {timestamp}, GPS: {gps_location}\n")
            
            speak("Photo accepted and saved.")
            break
        else:
            speak("Please retake the photo clearly. ")
            os.remove(image_path)

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
