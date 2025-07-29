local Switch = {}

type CaseCollection<A> = {
    Function: () -> (),
    Cases: {A}
}

export type Switch<A> = {
    Expression: A,

    CaseTree: { CaseCollection<A> },
    ElseCase: { () -> () },

    LastCaseCollection: {A},

    Case: (self: Switch<A>, case: A, caseMatching: () -> ()?) -> (Switch<A>),
    Else: (self: Switch<A>, noneMatching: () -> ()) -> (),
    End: (self: Switch<A>) -> (),
}

local function Switch_Case<A>(self: Switch<A>, case: A, caseMatching: () -> ()?): Switch<A>

    table.insert(self.LastCaseCollection, case)
    if (caseMatching) then
        table.insert(self.CaseTree, {
            Function = caseMatching,
            Cases = self.LastCaseCollection
        })

        self.LastCaseCollection = {}
    end

    return self
end

local function Switch_Else<A>(self: Switch<A>, noneMatching: () -> ())
    table.insert(self.ElseCase, noneMatching)

    table.insert(self.CaseTree, {
        Function = noneMatching,
        Cases = self.LastCaseCollection
    })

    self:End()
end

local function Switch_End<A>(self: Switch<A>)
    for _, v in self.CaseTree do
        for _, case in v.Cases do
            if not (case == self.Expression) then continue end
            v.Function()
            return
        end
    end

    for _, v in self.ElseCase do
        v()
    end
end

function Switch.Evaluate<A>(Expression: A): Switch<A>
    local newRoutine: Switch<A> = {
        Expression = Expression,

        CaseTree = {},
        ElseCase = {},
        LastCaseCollection = {},
        
        Case = Switch_Case,
        Else = Switch_Else,
        End = Switch_End,
    }

    return newRoutine
end

return Switch