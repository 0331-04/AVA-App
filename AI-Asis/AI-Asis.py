import time
import cv2
import os
from datetime import datetime
import geocoder


def speak(text):
    print("AI:", text)
    time.sleep(1)

def get_location():
    g = geocoder.ip ('me')
    if g.ok:
        return f"{g.city}, {g.country}"
    else:
        return "Unknown location"

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
    

def capturePhoto (photo_name, save_dir):

    if save_dir is None:
        save_dir = "accident _photos"

    os.makedirs(save_dir, exist_ok=True)
    save_path = None

    cap =cv2.VideoCapture(0, cv2.CAP_DSHOW)
    time.sleep(2)

    if not cap.isOpened():
        speak("Retrying camera...")
        cap = cv2.VideoCapture(0)
        time.sleep(2)

    if not cap.isOpened():
        speak ("Camera could not be opened.")
        return None
    
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

        if is_too_dark(image_path):
            speak("The photo os too dark. Please use flash and retake.")
            os.remove(image_path)
            continue  


        if is_blurry(image_path):
            speak("The photo is blurry. Please retake it clearly.")
            os.remove(image_path)
            continue

        img= cv2.imread(image_path)

        if img is not None:
            cv2.imshow("Photo Preview - Enter to Keep / Delete to retake", img)
            speak("Preveiew shown. Press Enter to keep the photo or DELETE to retake")

            key = cv2.waitKey(0)
            cv2.destroyAllWindows()

            if key == 13:

                timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                location=get_location()

                cv2.putText(img, timestamp, (20, 30),
                            cv2.Font_HERSHEY_SIMPLEX, 0.7,(0,255,0), 2)
                
                cv2.putText(img, location, (20,60),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.7,(0,255,0), 2)
                
                cv2.imwrite(image_path, img)

                with open(os.path.join(save_dir, "photo_log.txt" ), "a") as f:
                    f.write(f"{photo_name} captured at {timestamp}, Location: {location}\n")

                speak("photo accecepted and saved")
                break

            elif key == 127:
                speak("photo deleted. Please retake the photo.")
                os.remove(image_path)
                continue
        

def start_assistant():
    speak("Hello. I am your accident assistance AI.")
    speak("Please make sure you are safe and the vehicle is stopped.")
    speak("I will guide you to take photo for damage estimation.")


    photo_steps = [
        ("Take a FRONT side photo of the damage area.", "front.jpg"),
        
    ]

    save_dir="accident_photos"

    for step,filename in photo_steps:
        take_photo_step(step, filename, save_dir)

    speak("Photo has been captured successfully.")
    speak("You may now upload this image for quick estimate.")
    speak("Thank you. Drive safe.")

if __name__ == "__main__":
    start_assistant()
