from datetime import datetime

class Professor():
    hour = ""
    subject = ""
    clas = ""
    schoolroom = ""
    change = ""
    professor = ""
    reason = ""

    def get_supl(self, sibling, sibling_index):
        # HOUR
        if sibling_index == 0:
            try:
                self.hour = text(sibling)
            except:
                self.hour = ""
        # CHANGE
        elif sibling_index == 1:
            try:
                self.change = text(sibling)
            except:
                self.change = ""
        # SUBJECT
        elif sibling_index == 2:
            try:
                self.subject = text(sibling)
            except:
                self.subject = ""
        # CLAS
        elif sibling_index == 3:
            try:
                self.clas = text(sibling)
            except:
                self.clas = ""
        # SCHOOLROOM
        elif sibling_index == 4:
            try:
                sibling_wo_brackets = sibling.p.text.replace("(", "").replace(")", "")
                self.schoolroom = sibling_wo_brackets.encode('utf-8')
            except:
                self.schoolroom = ""
        # PROFESSOR USUAL
        elif sibling_index == 5:
            try:
                self.reason = text(sibling)
            except:
                self.reason = ""
        else:
            return True

def text(sibling):
    return sibling.p.text.encode('utf-8')

def is_change_same(change, professor):
    i = 0
    for property in change:
        if i == 1:
            date = datetime.strptime(professor.date, "%Y-%m-%d")
            if date != property:
                return False
        # TODO: Figure out how not to use ascii ignore
        if i == 2:
            if professor.hour != "":
                if professor.hour != property:
                    return False
            else:
                if professor.hour != property:
                    return False
        if i == 3:
            if professor.change != "":
                if professor.change != property:
                    return False
            else:
                if professor.change != property:
                    return False

        if i == 4:
            if professor.subject != "":
                if professor.subject != property:
                    return False
            else:
                if professor.subject != property:
                    return False
        i += 1
    return True

