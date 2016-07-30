import re
from datetime import datetime


class Supl():
    date = None
    hour = ""
    subject = ""
    group = ""
    schoolroom = ""
    change = ""
    professorForChange = ""
    professorUsual = ""

    def get_supl(self, sibling, sibling_index):
        # HOUR
        if sibling_index == 0:
            try:
                self.hour = text(sibling)
            except:
                self.hour = ""
        # SUBJECT
        elif sibling_index == 1:
            self.subject = text(sibling)
        # GROUP
        elif sibling_index == 2:
            try:
                self.group = text(sibling)
            except:
                self.group = ""
        # SCHOOLROOM
        elif sibling_index == 3:
            try:
                sibling_wo_brackets = sibling.p.text.replace("(", "").replace(")", "")
                self.schoolroom = sibling_wo_brackets.encode('utf-8')
            except:
                self.schoolroom = ""
        # CHANGE
        elif sibling_index == 4:
            try:
                sibling_wo_arrows = sibling.p.text.replace(">", "").replace("<", "").replace(" ", "")
                self.change = sibling_wo_arrows.encode('utf-8')
            except:
                self.change = ""
        # PROFESSOR FOR CHANGE
        elif sibling_index == 5:
            try:
                self.professorForChange = text(sibling)
            except:
                self.professorForChange = ""
        # PROFESSOR USUAL
        elif sibling_index == 6:
            try:
                string = sibling.p.text
                string = re.sub(r'[()]*', '', string)
                self.professorUsual = string.encode('utf-8')
            except:
                self.professorUsual = ""

def text(sibling):
    return sibling.p.text.encode('utf-8')

def is_supl_same(change, supl):
    i = 0
    for property in change:
        if i == 1:
            date = datetime.strptime(supl.date, "%Y-%m-%d")
            if date != property:
                return False
        # TODO: Figure out how not to use ascii ignore
        if i == 2:
            if supl.hour != "":
                if supl.hour != property:
                    return False
            else:
                if supl.hour != property:
                    return False
        if i == 3:
            if supl.change != "":
                if supl.change != property:
                    return False
            else:
                if supl.change != property:
                    return False

        if i == 4:
            if supl.subject != "":
                if supl.subject != property:
                    return False
            else:
                if supl.subject != property:
                    return False
        i += 1
    return True