from faker import Faker
from os import environ
fake = Faker()
module = environ["ESPANSO_MODULE"]
print(getattr(fake, module)())