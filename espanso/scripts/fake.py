from faker import Faker
from os import environ
import sys
fake = Faker()
if len(sys.argv) > 1 and sys.argv[1]:
    module = sys.argv[1]
else:
    module = environ["ESPANSO_MODULE"]
print(getattr(fake, module)())
