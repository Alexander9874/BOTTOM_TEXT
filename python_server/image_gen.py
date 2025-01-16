from db import db_GetProjectGrid

from PIL import Image
import numpy as np

colors = {
    0: (0, 0, 0),        # Черный
    1: (0, 0, 255),      # Синий
    2: (0, 255, 0),      # Зеленый
    3: (255, 0, 255),    # Фиолетовый
    4: (255, 0, 0)       # Красный
}

def ImageGen(projectname : str):
    data = db_GetProjectGrid(projectname)
    if data:
        data = data[0][0]
    else:
        return

    if len(data) != 6400:
        return

    matrix = np.array(data).reshape((80, 80))

    image = Image.new("RGB", (80, 80))

    pixels = image.load()
    
    for y in range(80):
        for x in range(80):
            pixels[y, x] = colors[matrix[y, x]]

    return image    

    image.save(projectname + ".png")

    image.show()

ImageGen("NEW_project_name")
ImageGen("project24")
ImageGen("404")
